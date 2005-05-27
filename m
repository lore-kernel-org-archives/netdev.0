From: Jian Jun He <hejianj@cn.ibm.com>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test
 on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 14:18:07 +0800
Message-ID: <OF8C2BEBF0.DC03FA25-ON4825700E.001E3C15-4825700E.0022793E@cn.ibm.com>
References: <20050526133123.47824405.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85"
Cc: anton@samba.org, Dang En Ren <rende@cn.ibm.com>,
        ganesh.venkatesan@gmail.com, ganesh.venkatesan@intel.com,
        herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
        jgarzik@pobox.com, Jia Sen Wang <wangjs@cn.ibm.com>,
        john.ronciak@intel.com, Lei CDL Wang <cdlwangl@cn.ibm.com>,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050526133123.47824405.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: multipart/related;
	Boundary="1__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85"

--1__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: multipart/alternative;
	Boundary="2__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85"

--2__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable



hello,

I verified the problem on 2.6.12-rc5 with mm1 patch. The test server wo=
rks
find during the test procedure.
So I will close this defect in bugme.

Thanks all of your attention on this defect.


to Andrew Morton:

1)If you are a register in rhn.redhat.com, you can search the package
"rhr2", then you can download rhr2.
Also you could download rhr2 from the following links
http://people.redhat.com/rlandry/rhr2/test/1.0-17beta/rhr2-1.0-17beta.n=
oarch.rpm

2)The attachments are the conf files that I used for rhr2 test.


(See attached file: hardware.conf)(See attached file: rhr.conf)(See
attached file: system.conf)(See attached file: tests.conf)
3) invoke redhat-ready is ok, no arguments.

Best Regards!

Jian Jun He

CSDL, Beijing
Email: hejianj@cn.ibm.com



                                                                       =
    
             Andrew Morton                                             =
    
             <akpm@osdl.org>                                           =
    
                                                                       =
 To 
             2005-05-27 04:31          Jian Jun He/China/Contr/IBM@IBMC=
N   
                                                                       =
 cc 
                                       ganesh.venkatesan@intel.com,    =
    
                                       anton@samba.org, Dang En        =
    
                                       Ren/China/IBM@IBMCN,            =
    
                                       ganesh.venkatesan@gmail.com,    =
    
                                       herbert@gondor.apana.org.au,    =
    
                                       jesse.brandeburg@intel.com,     =
    
                                       jgarzik@pobox.com, Jia Sen      =
    
                                       Wang/China/IBM@IBMCN,           =
    
                                       john.ronciak@intel.com, Lei CDL =
    
                                       Wang/China/Contr/IBM@IBMCN,     =
    
                                       linuxppc64-dev@lists.linuxppc.or=
g.s 
                                       gi.com, netdev@oss.sgi.com      =
    
                                                                   Subj=
ect 
                                       Re: Fw: [Bugme-new] [Bug 4628] N=
ew: 
                                       Test server hang while running r=
hr  
                                       (network) test on RHEL4 with ker=
nel 
                                       2.6.12-rc1-mm4                  =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




Jian Jun He <hejianj@cn.ibm.com> wrote:
>
>  2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.com and
install
>  it on
>  the test machine.
>  3. Configure and run the rhr test via invoking redhat-ready.

This is the problematic bit.

- Please provide a full URL which can be used to obtain rhr.
  rhn.redhat.com is subscription-based.

- Please describe the hardware setup - surely the test requires at leas=
t
  two machines.  How are they configured?

- Provide an exact transcript of the commands which are to be used.  Is=

  it just

             redhat-ready

  with no arguments?



All that begin said, we already have a quite specific diagnosis via cod=
e
inspection, from Herbert:


Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > Might be a bug in the e100 driver, might not be.
> >
> > I assume this is the
> >
> >        BUG_ON(skb->list !=3D NULL);
>
> It certainly is a bug in e100.
>
> e100_tx_timeout -> e100_down -> e100_rx_clean_list
>
> is racing against
>
> e100_poll -> e100_rx_clean -> e100_rx_indicate
>
> e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and
> while it's being processed e100_rx_clean_list comes along and
> frees it.
>
> From a quick check similar problems may exist in other drivers that
> have lockless ->poll() functions with RX rings.

Do the e100 maintainers agree with this diagnosis?  If so then more tes=
ting
isn't required at this stage - the next step is to fix the above bug, n=
o?

=

--2__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>hello,<br>
<br>
I verified the problem on 2.6.12-rc5 with mm1 patch. The test server wo=
rks find during the test procedure. <br>
So I will close this defect in bugme.<br>
<br>
Thanks all of your attention on this defect.<br>
<br>
<br>
to <b><font size=3D"2">Andrew Morton</font></b>:<br>
<br>
1)If you are a register in rhn.redhat.com, you can search the package &=
quot;rhr2&quot;, then you can download rhr2. <br>
Also you could download rhr2 from the following links <a href=3D"http:/=
/people.redhat.com/rlandry/rhr2/test/1.0-17beta/rhr2-1.0-17beta.noarch.=
rpm">http://people.redhat.com/rlandry/rhr2/test/1.0-17beta/rhr2-1.0-17b=
eta.noarch.rpm</a><br>
<br>
2)The attachments are the conf files that I used for rhr2 test.<br>
<br>
<br>
<i>(See attached file: hardware.conf)</i><i>(See attached file: rhr.con=
f)</i><i>(See attached file: system.conf)</i><i>(See attached file: tes=
ts.conf)</i><br>
3) invoke redhat-ready is ok, no arguments.<br>
<br>
Best Regards!<br>
<br>
Jian Jun He<br>
<br>
CSDL, Beijing<br>
Email: hejianj@cn.ibm.com<br>
<br>
<img width=3D"16" height=3D"16" src=3D"cid:5__=3DC7BBFA9DDF8DBA858f9e8a=
93df938@cn.ibm.com" border=3D"0" alt=3D"Inactive hide details for Andre=
w Morton &lt;akpm@osdl.org&gt;">Andrew Morton &lt;akpm@osdl.org&gt;<br>=

<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:6__=3DC7BBFA9D=
DF8DBA858f9e8a93df938@cn.ibm.com); background-repeat: no-repeat; " widt=
h=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">Andrew Morton &lt;akpm@osdl.org&gt;</font></b><=
font size=3D"2"> </font>
<p><font size=3D"2">2005-05-27 04:31</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:7__=3DC7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:7__=3DC7BBFA9DDF8DBA858f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Jian Jun He/China/Contr/IBM@IBMCN</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:7__=3DC7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:7__=3DC7BBFA9DDF8DBA858f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">ganesh.venkatesan@intel.com, anton@samba.org, Dang En =
Ren/China/IBM@IBMCN, ganesh.venkatesan@gmail.com, herbert@gondor.apana.=
org.au, jesse.brandeburg@intel.com, jgarzik@pobox.com, Jia Sen Wang/Chi=
na/IBM@IBMCN, john.ronciak@intel.com, Lei CDL Wang/China/Contr/IBM@IBMC=
N, linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com</font>=
</td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:7__=3DC7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img width=3D"1" height=3D"1" src=3D"cid:7__=3DC7BBFA9DDF8DB=
A858f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang w=
hile running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4</fo=
nt></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img width=3D"1" height=3D"1" src=3D=
"cid:7__=3DC7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D=
""></td><td width=3D"336"><img width=3D"1" height=3D"1" src=3D"cid:7__=3D=
C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""></td></=
tr>
</table>
</td></tr>
</table>
<br>
<tt>Jian Jun He &lt;hejianj@cn.ibm.com&gt; wrote:<br>
&gt;<br>
&gt; &nbsp;2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.co=
m and install<br>
&gt; &nbsp;it on<br>
&gt; &nbsp;the test machine.<br>
&gt; &nbsp;3. Configure and run the rhr test via invoking redhat-ready.=
<br>
<br>
This is the problematic bit.<br>
<br>
- Please provide a full URL which can be used to obtain rhr. <br>
 &nbsp;rhn.redhat.com is subscription-based.<br>
<br>
- Please describe the hardware setup - surely the test requires at leas=
t<br>
 &nbsp;two machines. &nbsp;How are they configured?<br>
<br>
- Provide an exact transcript of the commands which are to be used. &nb=
sp;Is<br>
 &nbsp;it just <br>
<br>
		 redhat-ready<br>
<br>
 &nbsp;with no arguments?<br>
<br>
<br>
<br>
All that begin said, we already have a quite specific diagnosis via cod=
e<br>
inspection, from Herbert:<br>
<br>
<br>
Herbert Xu &lt;herbert@gondor.apana.org.au&gt; wrote:<br>
&gt;<br>
&gt; Andrew Morton &lt;akpm@osdl.org&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; Might be a bug in the e100 driver, might not be.<br>
&gt; &gt;<br>
&gt; &gt; I assume this is the<br>
&gt; &gt;<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp;BUG_ON(skb-&gt;list !=3D NULL);<br=
>
&gt;<br>
&gt; It certainly is a bug in e100.<br>
&gt;<br>
&gt; e100_tx_timeout -&gt; e100_down -&gt; e100_rx_clean_list<br>
&gt;<br>
&gt; is racing against<br>
&gt;<br>
&gt; e100_poll -&gt; e100_rx_clean -&gt; e100_rx_indicate<br>
&gt;<br>
&gt; e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and<br=
>
&gt; while it's being processed e100_rx_clean_list comes along and<br>
&gt; frees it.<br>
&gt;<br>
&gt; From a quick check similar problems may exist in other drivers tha=
t<br>
&gt; have lockless -&gt;poll() functions with RX rings.<br>
<br>
Do the e100 maintainers agree with this diagnosis? &nbsp;If so then mor=
e testing<br>
isn't required at this stage - the next step is to fix the above bug, n=
o?<br>
<br>
</tt><br>
</body></html>=


--2__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85--


--1__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <5__=C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--1__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: image/gif;
	name="pic09902.gif"
Content-Disposition: inline; filename="pic09902.gif"
Content-ID: <6__=C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com>
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

--1__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <7__=C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7


--1__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85--


--0__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: application/octet-stream;
	name="hardware.conf"
Content-Disposition: attachment; filename="hardware.conf"
Content-ID: <1__=C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

IwojIGhhcmR3YXJlLmNvbmYgLSBnZW5lcmF0ZWQgb24gRnJpIE1heSAyNyAwMDo0MTo0NiBFRFQg
MjAwNQojCgojIERFU0NSSVBUSU9OOiAgVGhpcyBmaWxlIGNvbnRhaW5zIHRoZSBoYXJkd2FyZSBj
bGFzcyBmb2xsb3dlZCBieSBhbnkgb3B0aW9ucwojIHJlcXVpcmVkIGJ5IHRoYXQgY2xhc3MgdGVz
dHM7IHVzdWFsbHkgdG8gaW5jbHVkZSB0aGUgZGV2aWNlIG9yIG51bWJlciBvZgojIGRldmljZXMg
dG8gdGVzdHMuCiMKIyBDSEFOR0VTOiAgVGhlIGxhcmdlc3QgY2hhbmdlIGlzIHRoYXQgdGhpcyBm
aWxlIGlzIG5vdyBnZW5lcmF0ZWQgaW5zdGVhZCBvZgojIG1hbnVhbGx5IHBvcHVsYXRlZC4gIFdp
dGggYW55IGx1Y2sgdGhpcyBzaG91bGQgYXZvaWQgdGhlIG5lZWQgZm9yIGEgcGVyc29uCiMgdG8g
ZmlndXJlIGl0IG91dC4gIFRoZSBmb3JtYXQgaXMgbGFyZ2VseSBpbiB0YWN0IChjb21wYXJlZCB3
aXRoIHJoci5jb25mKSAKIyB3aXRoIHR3byBleGNlcHRpb25zOyB0aGUgcmVxdWlyZW1lbnQgdG8g
bGlzdCB0aGUgc2FtZSBkZXZpY2UgbXVsdGlwbGUgdGltZXMKIyBoYXMgYmVlbiBsaWZ0ZWQgKHlv
dSBtYXkgbm93IGFzc3VtZSB0aGUgdGVzdHMgd2lsbCBkbyB0aGUgcmlnaHQgdGhpbmcpIGFuZAoj
IHRoZSB0ZXN0IHNwZWNpZmljIGNvbmZpZ3VyYXRpb24gZGF0YSBpcyBub3cgaW4gL2V0Yy9yaHIv
dGVzdHMuY29uZjsgbW9yZSBha2luCiMgdG8gcmhyLWNydXNoIGFuZCBpdHMgL2V0Yy9yaHIva2Vy
bmVsLgoKIyBORVRXT1JLIGlmMSBbLi4uaWZOXQojICAgUmVxdWlyZXMgYSBzZXJ2ZXIgYW5kIHJl
bW90ZSB1c2VyIGFzIGNvbmZpZ3VyZWQgaW4gL2V0Yy9yaHIvdGVzdHMuY29uZi4KIyAgIFRoZSBy
ZW1vdGUgdXNlciB3aWxsIG5lZWQgYWIgYW5kIG1vdW50IHByaXZpbGVnZXM7IHRoZSBzZXJ2ZXIg
aXMgZXhwZWN0ZWQKIyAgIHRvIE5PVCBiZSBpbiBhIHByb2R1Y3Rpb24gZW52aXJvbm1lbnQgYXMg
bm8gcGFzc3dvcmQgbG9naW5zIGFyZSBlbmFibGVkCiMgICBkdXJpbmcgdGVzdGluZy4KIwojICpO
T1RFOiBPbiBzMzkwL3MzOTB4IHlvdSBtYXkgbmVlZCB0byBtYW51YWxseSBjcmVhdGUgdGhlIG5l
dHdvcmsgc2NyaXB0cy4KIyAgICAgICAgU2VlIHRoZSBSRUxFQVNFLU5PVEVTIGZvciBkZXRhaWxz
LgpORVRXT1JLIGV0aDAoMTAwKQoKIyBTVE9SQUdFIC0gbGlzdCBkZXZpY2VzOyBpbmNsdWRlcyBi
b3RoIGZpeGVkIGRpc2tzLCByZW1vdmFibGUsIGFuZCBNVEQncy4KU1RPUkFHRSBzZGMKCiMgQ09S
RSAobm8gcGFyYW1ldGVycykKIyAgIFdoaWxlIHRoZXJlIG5vIHBhcmFtZXRlcnMgaGVyZTsgYSBr
ZXJuZWwgc291cmNlIFJQTSBwYWNrYWdlIGlzIHJlcXVpcmVkIGZvciAjICAgdGVzdGluZy4gIFRo
ZSBwYWNrYWdlIGxvY2F0aW9uIGlzIGNvbmZpZ3VyZWQgaW4gL2V0Yy9yaHIvdGVzdHMuY29uZiBh
bmQgaXMKIyAgIHNoYXJlZCBieSBNRU1PUlkKQ09SRSAKCiMgTUVNT1JZIChubyBwYXJhbWV0ZXJz
KQojICAgV2hpbGUgdGhlcmUgbm8gcGFyYW1ldGVycyBoZXJlOyBhIGtlcm5lbCBzb3VyY2UgUlBN
IHBhY2thZ2UgaXMgcmVxdWlyZWQgZm9yICMgICB0ZXN0aW5nLiAgVGhlIHBhY2thZ2UgbG9jYXRp
b24gaXMgY29uZmlndXJlZCBpbiAvZXRjL3Joci90ZXN0cy5jb25mIGFuZCBpcwojICAgc2hhcmVk
IGJ5IENPUkUuCk1FTU9SWSAKCg==

--0__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: application/octet-stream;
	name="rhr.conf"
Content-Disposition: attachment; filename="rhr.conf"
Content-ID: <2__=C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

IwojIHJoci5jb25mIC0gZ2VuZXJhdGVkIFN1biBBdWcgMTAgMjM6MDQ6NDUgRURUIDIwMDMKIwoK
IyBEZXNjcmlwdGlvbjogIEFsbG93cyBmb3IgdGhlIHVzZSBvZiBhbHRlcm5hdGUgbG9jYXRpb25z
IGZvciB0aGUgc2NyYXRjaCBhbmQKIyByZXN1bHQgZmlsZXMuICBUaGlzIHByZXZlbnRzIHRoZSBu
ZWVkIGZvciBiaW5kLW1vdW50cyBhbmQgYW55IG90aGVyIHZvb2RvbwojIHRoYXQgY291bGQgYWR2
ZXJzZWx5IGVmZmVjdCB0aGUgdGVzdHMuICBEZWZhdWx0cyBoYXZlIGJlZW4gY29kZWQgaW50byB0
aGUKIyBhcHBsaWNhdGlvbiBzbyBjb25maWd1cmF0aW9uIGlzIG5vdCByZXF1aXJlZC4gIFRvIG92
ZXJyaWRlIHRoZXNlIHZhbHVlcywKIyB1bmNvbW1lbnQgdGhlIHNldHRpbmcgbGluZSBhbmQgbW9k
aWZ5IGFzIG5lZWRlZC4KCiMgcnVudGltZSB0ZW1wb3JhcnkgZmlsZXMuClNDUkFUQ0g9L3RtcC9y
aHIKCiMgcmVzdWx0cyBwYWNrYWdlIGxvY2F0aW9uLgpSRVNVTFRTPS9yZWRoYXRyZWFkeQo=

--0__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: application/octet-stream;
	name="system.conf"
Content-Disposition: attachment; filename="system.conf"
Content-ID: <3__=C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

IwojIHN5c3RlbS5jb25mIC0gZ2VuZXJhdGVkIG9uIEZyaSBNYXkgMjcgMDA6NDE6MzUgRURUIDIw
MDUKIyAKCiMgREVTQ1JJUFRJT046ICBDb250YWlucyB0aGUgbWFrZS9tb2RlbC9yZWxlYXNlIGNv
bWJpbmF0aW9uIGZvciBIQ0wgbGlzdGluZwojIGFuZCByZXN1bHRzIHBhY2thZ2UgY3JlYXRpb24u
IAoKTUFLRT0ibWFrZSIKTU9ERUw9IklCTSw5MTI0LTcyMCIKUkhSRUxFQVNFPSJOYWhhbnQiCg==

--0__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85
Content-type: application/octet-stream;
	name="tests.conf"
Content-Disposition: attachment; filename="tests.conf"
Content-ID: <4__=C7BBFA9DDF8DBA858f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

IwojIHRlc3RzLmNvbmYgLSB0ZXN0IHNwZWNpZmljIGNvbmZpZ3VyYXRpb24gZmlsZQojCgoKIwoj
IENPUkUKIwojICBTUlBNIC0gUmVxdWlyZWQga2VybmVsIHNvdXJjZSBycG0gcGFja2FnZTsgaWYg
bm90IHNldCwgQ09SRSB3aWxsIGF0dGVtcHQKIyAgICAgICAgIHRvIGxvY2F0ZSBhbmQgdXNlIHRo
ZSBmaXJzdCBrZXJuZWwtKi5zcmMucnBtIGZpbGUgaXQgZmluZCBpbiAvdG1wLgojClNSUE09Ii90
bXAva2VybmVsLTIuNi45LTEuOTA2LjIuMV9FTC5wYXRjaHRlc3QuMTUuc3JjLnJwbSIKCiMKIyBD
RFJPTQojCiMgIElTTyAtIFVzZWQgZm9yIGNkLXIgYW5kIGNkLXJ3IHRlc3Rpbmc7IGNkcm9tIHRl
c3RpbmcgcmVxdWlyZXMgYSBwaHlzaWNhbCBDRC4KIyAgICAgICAgV2UncmUgbm90IHNwZWNpZmlj
IG9uIHdoYXQgaGFzIHRvIGJlIG9uIHRoZSBpc287IGhvd2V2ZXIgaXQgc2hvdWxkIGJlCiMgICAg
ICAgIG9mIGEgcmVhc29uYWJsZSBzaXplLiAgR2VuZXJhbGx5IHdlIHJlY29tZW5kIGRpc2MgMSBv
ZiB0aGUgaW5zdGFsbCBzZXQuCiMgICAgICAgIExpa2UgU1JQTSBhYm92ZTsgaWYgbm90IHNldCB3
ZSdsbCBzZXR0bGUgZm9yIHdoYXQgd2UgY2FuIGZpbmQgaW4gL3RtcC4KIwojICBOT1RFOiBJRiBj
ZC1yKHcpIGFuZCBkdmQtcih3KSBhcmUgdG8gYmUgcnVuIGluIHRoZSBzYW1lIHBhc3MsIGVhY2gg
aXNvCiMgICAgICAgIG11c3QgYmUgc3BlY2lmaWVkIGJlbG93LgojCiNDRElTTz0iL3RtcC90YXJv
b24taTM4Ni1hcy1kaXNjMS5pc28iCiNEVkRJU089Ii90bXAvdGFyb29uLWkzODYtYXMtZGlzYzEu
aXNvIgoKCiMKIyBORVRXT1JLOgojCiMgIFJIUlVTRVIgLSBUaGUgdXNlciB1c2VkIHRvIGxvZyBp
bnRvIHRoZSByZW1vdGUgbWFjaGluZTsgc2hvdWxkIGhhdmUKIyAgICAgICAgICAgIGFuIHNzaCBz
aGVsbCBhY2NvdW50IGFuZCBwZXJtaXNzaW9ucyB0byBleGVjdXRlIGFiIChhcGFjaGUgYmVuY2gp
LAojICAgICAgICAgICAgYW5kIG1vdW50IGZpbGUgc3lzdGVtcy4gIFRoZSBkZWZhdWx0IHVzZXIg
aXMgcm9vdC4KIwpSSFJVU0VSPSJyb290IgojCiMgIFNFUlZFUiAtIFRoZSByZW1vdGUgbWFjaGlu
ZSB0byBiZSBjb250YWN0ZWQ7IHNob3VsZCBjb250YWluIHRoZSBSSFJVU0VSIGFuZAojICAgICAg
ICAgICBoYXZlIGFwYWNoZSBiZW5jaCAoYWIpIGFuZCBiZSBhYmxlIHRvIG1vdW50IE5GUzsgZGVm
YXVsdHMgdG8KIyAgICAgICAgICAgMTkyLjE2OC4wLjEuCiMKU0VSVkVSPSI5LjMuMTg5LjYxIgo=

--0__=C7BBFA9DDF8DBA858f9e8a93df938690918cC7BBFA9DDF8DBA85--
