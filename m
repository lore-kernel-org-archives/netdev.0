From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: RE: IPv4 and IPv6 stack multi-FIB, scalable in the million of entries.
Date: Thu, 8 Apr 2004 14:16:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5907104A.965FEB06-ON88256E70.0074BB8E@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E"
Cc: ak@muc.de, "David S. Miller" <davem@redhat.com>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E
Content-type: multipart/alternative;
	Boundary="1__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E"

--1__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E
Content-type: text/plain; charset=US-ASCII





Hi Mathieu,

It is a sysctl changable parameter, look at ip_rt_max_size or in sysctl -a
for max_size.
Linux supports infinite routes :-)

- KK



|---------+----------------------------->
|         |           "Mathieu Giguere" |
|         |           <Mathieu.Giguere@e|
|         |           ricsson.ca>       |
|         |           Sent by:          |
|         |           netdev-bounce@oss.|
|         |           sgi.com           |
|         |                             |
|         |                             |
|         |           04/08/2004 12:53  |
|         |           PM                |
|         |                             |
|---------+----------------------------->
  >--------------------------------------------------------------------------------------------------------------|
  |                                                                                                              |
  |       To:       <linux-kernel@vger.kernel.org>, "David S. Miller" <davem@redhat.com>                         |
  |       cc:       <ak@muc.de>, <netdev@oss.sgi.com>                                                            |
  |       Subject:  RE: IPv4 and IPv6 stack multi-FIB, scalable in the million of entries.                       |
  |                                                                                                              |
  >--------------------------------------------------------------------------------------------------------------|




 Hi,

     Just run the join script on your favorite 2.4 kernel.

 RTNETLINK answers: Cannot allocate memory
 RTNETLINK answers: Cannot allocate memory
 RTNETLINK answers: Cannot allocate memory
 [root@tom tmp]# ip -6 route | wc -l
    4094
 [root@tom tmp]#


     And after 4094 IPv6 routes you will the get the same.

     For the PMTU, the info can't be retain in the route himself.  The PTMU
 is base on DIP not on the current network routing.  So it must be kept in
a
 separate hash struct with expire time.  _BUT_ you must not flush all the
 entries each time a route is added or  deleted like in the current
 implementation.

 /mathieu


 -------------------------------
 #!/bin/csh
 echo #!/bin/sh
 set addr1=0
 set addr2=1
 while ($addr1 < 256)
   while ($addr2 < 256)
     echo ip -f inet6 route add 2000:${addr1}::${addr2}/128 dev eth0
     @ addr2++
   end
   set addr2=0
   @ addr1++
 end


 ----- Original Message -----
 From: "David S. Miller" <davem@redhat.com>
 To: "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca>
 Cc: <ak@muc.de>; <netdev@oss.sgi.com>; <linux-kernel@vger.kernel.org>
 Sent: Thursday, April 08, 2004 2:33 PM
 Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of
 entries.


 > On Thu, 8 Apr 2004 14:10:43 -0400
 > "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca> wrote:
 >
 > > The main goal to remove the routing cache is to avoid to have 4096
 routes
 > > limitation
 >
 > This 4K routes limitation is news to everyone who works on this
 > code.
 >
 > When nexthop changes we _MUST_ flush PMTU etc. information because that
 > could have changed.  If however, such information is locked into the
 > route itself, it will propagate immediately into the routing cache
 > entry once recreated.
 >
 > You seem to be talking about a lot of non-problems, but this may because
 > you're not providing enough details.
 >




--1__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Hi Mathieu,<br>
<br>
It is a sysctl changable parameter, look at ip_rt_max_size or in sysctl -a for max_size.<br>
Linux supports infinite routes :-)<br>
<br>
- KK<br>
<br>
<img src="cid:10__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com" width="16" height="16" alt="Inactive hide details for &quot;Mathieu Giguere&quot; &lt;Mathieu.Giguere@ericsson.ca&gt;">&quot;Mathieu Giguere&quot; &lt;Mathieu.Giguere@ericsson.ca&gt;<br>
<br>
<br>

<table V5DOTBL=true width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top"><td width="1%"><img src="cid:20__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com" border="0" height="1" width="72" alt=""><br>
</td><td style="background-image:url(cid:30__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " width="1%"><img src="cid:20__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com" border="0" height="1" width="225" alt=""><br>

<ul>
<ul>
<ul>
<ul><b><font size="2">&quot;Mathieu Giguere&quot; &lt;Mathieu.Giguere@ericsson.ca&gt;</font></b><br>
<font size="2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size="2">04/08/2004 12:53 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width="100%"><img src="cid:20__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com" border="0" height="1" width="1" alt=""><br>
<font size="1" face="Arial">	</font><br>
<font size="2">	To:	</font><font size="2">&lt;linux-kernel@vger.kernel.org&gt;, &quot;David S. Miller&quot; &lt;davem@redhat.com&gt;</font><br>
<font size="2">	cc:	</font><font size="2">&lt;ak@muc.de&gt;, &lt;netdev@oss.sgi.com&gt;</font><br>
<font size="2">	Subject:	</font><font size="2">RE: IPv4 and IPv6 stack multi-FIB, scalable in the million of entries.</font></td></tr>
</table>
<br>
<br>
<font face="Courier New"> Hi,<br>
<br>
     Just run the join script on your favorite 2.4 kernel.<br>
<br>
 RTNETLINK answers: Cannot allocate memory<br>
 RTNETLINK answers: Cannot allocate memory<br>
 RTNETLINK answers: Cannot allocate memory<br>
 [root@tom tmp]# ip -6 route | wc -l<br>
    4094<br>
 [root@tom tmp]#<br>
<br>
<br>
     And after 4094 IPv6 routes you will the get the same.<br>
<br>
     For the PMTU, the info can't be retain in the route himself.  The PTMU<br>
 is base on DIP not on the current network routing.  So it must be kept in a<br>
 separate hash struct with expire time.  _BUT_ you must not flush all the<br>
 entries each time a route is added or  deleted like in the current<br>
 implementation.<br>
<br>
 /mathieu<br>
<br>
<br>
 -------------------------------<br>
 #!/bin/csh<br>
 echo #!/bin/sh<br>
 set addr1=0<br>
 set addr2=1<br>
 while ($addr1 &lt; 256)<br>
   while ($addr2 &lt; 256)<br>
     echo ip -f inet6 route add 2000:${addr1}::${addr2}/128 dev eth0<br>
     @ addr2++<br>
   end<br>
   set addr2=0<br>
   @ addr1++<br>
 end<br>
<br>
<br>
 ----- Original Message ----- <br>
 From: &quot;David S. Miller&quot; &lt;davem@redhat.com&gt;<br>
 To: &quot;Mathieu Giguere&quot; &lt;Mathieu.Giguere@ericsson.ca&gt;<br>
 Cc: &lt;ak@muc.de&gt;; &lt;netdev@oss.sgi.com&gt;; &lt;linux-kernel@vger.kernel.org&gt;<br>
 Sent: Thursday, April 08, 2004 2:33 PM<br>
 Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of<br>
 entries.<br>
<br>
<br>
 &gt; On Thu, 8 Apr 2004 14:10:43 -0400<br>
 &gt; &quot;Mathieu Giguere&quot; &lt;Mathieu.Giguere@ericsson.ca&gt; wrote:<br>
 &gt;<br>
 &gt; &gt; The main goal to remove the routing cache is to avoid to have 4096<br>
 routes<br>
 &gt; &gt; limitation<br>
 &gt;<br>
 &gt; This 4K routes limitation is news to everyone who works on this<br>
 &gt; code.<br>
 &gt;<br>
 &gt; When nexthop changes we _MUST_ flush PMTU etc. information because that<br>
 &gt; could have changed.  If however, such information is locked into the<br>
 &gt; route itself, it will propagate immediately into the routing cache<br>
 &gt; entry once recreated.<br>
 &gt;</font><br>
<font face="Courier New"> &gt; You seem to be talking about a lot of non-problems, but this may because<br>
 &gt; you're not providing enough details.<br>
 &gt;<br>
<br>
<br>
</font>

</body></html>

--1__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E--


--0__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <20__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E
Content-type: image/gif;
	name="pic00583.gif"
Content-Disposition: inline; filename="pic00583.gif"
Content-ID: <30__=07BBE4E3DFE73D1E8f9e8a93df938@us.ibm.com>
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

--0__=07BBE4E3DFE73D1E8f9e8a93df938690918c07BBE4E3DFE73D1E--
