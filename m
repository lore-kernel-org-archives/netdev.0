From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: nf_unregister_hook crashing kernel
Date: Thu, 22 Apr 2004 14:08:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFD8032B89.E1DE811D-ON88256E7E.0073E203@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Correa <andre.correa@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493
Content-type: multipart/alternative;
	Boundary="1__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493"

--1__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493
Content-type: text/plain; charset=US-ASCII





If you do a nf_register_queue_handler, you need
nf_unregister_queue_handler. Can't mix
and match :-) Basically what is happening is that your list is not
initialized (actually set to
NULL being global), and when you do a de-register, it panics.

- KK



|---------+---------------------------->
|         |           Andre Correa     |
|         |           <andre.correa@pob|
|         |           ox.com>          |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           04/22/2004 04:51 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >-------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                         |
  |       To:       netdev@oss.sgi.com                                                                                      |
  |       cc:                                                                                                               |
  |       Subject:  nf_unregister_hook crashing kernel                                                                      |
  |                                                                                                                         |
  >-------------------------------------------------------------------------------------------------------------------------|





Hi list, I'm playing with a module that uses netfilter hooks. It
register using nf_register_hook without problems, but when I try
nf_unregister_hook in my "cleanup" function the kernel crashs. I've
found that it crashs calling nf_unregister_hook, but have no idea how to
debug it further...

Here goes some snips from my code. Nothing new. I've searched other
modules and found that everybody makes the same.


...<snip>...

static nf_hookfn my_nf_hook;


static struct nf_hook_ops my_ingress_ipv4 = {
        .hook           = my_nf_hook,
        .owner          = THIS_MODULE,
        .pf             = PF_INET,
        .hooknum        = NF_IP_PRE_ROUTING,
        .priority       = NF_IP_PRI_MANGLE + 1
};

...<snip>...

static unsigned int my_nf_hook(unsigned int hook, struct sk_buff **pskb,
                   const struct net_device *indev,
                   const struct net_device *outdev,
                   int (*okfn)(struct sk_buff *))
{
        if ((*pskb)->my_flags & MY_F_ENQUEUE)
                return NF_QUEUE;


        return NF_ACCEPT;
}

...<snip>...

static int __init my_init_hooks(void)
{
        int err;


        if ((err = nf_register_queue_handler(PF_INET, my_nf_queue, NULL)))
                return err;
}

...<snip>....

static void __exit my_unhook(void)
{

       nf_unregister_hook(&my_ingress_ipv4);
}

...<snip>...

module_init(my_init_module);
module_exit(my_cleanup_module);
MODULE_LICENSE("GPL");


Like I said, nothing new. Is there anybody who can give me some info on
how/when can nf_unregister_hook crash the kernel? How can I debug some
more?!

Tks in advance for any help.

Andre





--1__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>If you do a nf_register_queue_handler, you need nf_unregister_queue_handler. Can't mix<br>
and match :-) Basically what is happening is that your list is not initialized (actually set to<br>
NULL being global), and when you do a de-register, it panics.<br>
<br>
- KK<br>
<br>
<img src="cid:10__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com" width="16" height="16" alt="Inactive hide details for Andre Correa &lt;andre.correa@pobox.com&gt;">Andre Correa &lt;andre.correa@pobox.com&gt;<br>
<br>
<br>

<table V5DOTBL=true width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top"><td width="1%"><img src="cid:20__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com" border="0" height="1" width="72" alt=""><br>
</td><td style="background-image:url(cid:30__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " width="1%"><img src="cid:20__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com" border="0" height="1" width="225" alt=""><br>

<ul>
<ul>
<ul>
<ul><b><font size="2">Andre Correa &lt;andre.correa@pobox.com&gt;</font></b><br>
<font size="2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size="2">04/22/2004 04:51 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width="100%"><img src="cid:20__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com" border="0" height="1" width="1" alt=""><br>
<font size="1" face="Arial">	</font><br>
<font size="2">	To:	</font><font size="2">netdev@oss.sgi.com</font><br>
<font size="2">	cc:	</font><br>
<font size="2">	Subject:	</font><font size="2">nf_unregister_hook crashing kernel</font></td></tr>
</table>
<br>
<br>
<font face="Courier New"><br>
Hi list, I'm playing with a module that uses netfilter hooks. It <br>
register using nf_register_hook without problems, but when I try <br>
nf_unregister_hook in my &quot;cleanup&quot; function the kernel crashs. I've <br>
found that it crashs calling nf_unregister_hook, but have no idea how to <br>
debug it further...<br>
<br>
Here goes some snips from my code. Nothing new. I've searched other <br>
modules and found that everybody makes the same.<br>
<br>
<br>
...&lt;snip&gt;...<br>
<br>
static nf_hookfn my_nf_hook;<br>
 <br>
<br>
static struct nf_hook_ops my_ingress_ipv4 = {<br>
        .hook           = my_nf_hook,<br>
        .owner          = THIS_MODULE,<br>
        .pf             = PF_INET,<br>
        .hooknum        = NF_IP_PRE_ROUTING,<br>
        .priority       = NF_IP_PRI_MANGLE + 1<br>
};<br>
<br>
...&lt;snip&gt;...<br>
<br>
static unsigned int my_nf_hook(unsigned int hook, struct sk_buff **pskb,<br>
                   const struct net_device *indev,<br>
                   const struct net_device *outdev,<br>
                   int (*okfn)(struct sk_buff *))<br>
{<br>
        if ((*pskb)-&gt;my_flags &amp; MY_F_ENQUEUE)<br>
                return NF_QUEUE;<br>
 <br>
<br>
        return NF_ACCEPT;<br>
}<br>
<br>
...&lt;snip&gt;...<br>
<br>
static int __init my_init_hooks(void)<br>
{<br>
        int err;<br>
 <br>
<br>
        if ((err = nf_register_queue_handler(PF_INET, my_nf_queue, NULL)))<br>
                return err;<br>
}<br>
<br>
...&lt;snip&gt;....<br>
<br>
static void __exit my_unhook(void)<br>
{<br>
<br>
       nf_unregister_hook(&amp;my_ingress_ipv4);<br>
}<br>
<br>
...&lt;snip&gt;...<br>
<br>
module_init(my_init_module);<br>
module_exit(my_cleanup_module);<br>
MODULE_LICENSE(&quot;GPL&quot;);<br>
<br>
<br>
Like I said, nothing new. Is there anybody who can give me some info on <br>
how/when can nf_unregister_hook crash the kernel? How can I debug some <br>
more?!<br>
</font><br>
<font face="Courier New">Tks in advance for any help.<br>
<br>
Andre<br>
<br>
<br>
<br>
</font>

</body></html>

--1__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493--


--0__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <20__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493
Content-type: image/gif;
	name="pic14315.gif"
Content-Disposition: inline; filename="pic14315.gif"
Content-ID: <30__=07BBE4EDDFE064938f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=07BBE4EDDFE064938f9e8a93df938690918c07BBE4EDDFE06493--
