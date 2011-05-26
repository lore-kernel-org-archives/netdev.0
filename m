From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PERF RESULTS] virtio and vhost-net performance enhancements
Date: Thu, 26 May 2011 08:42:22 -0700
Message-ID: <OFE30C8D78.526FF88D-ON8725789C.00563B8C-8825789C.0056469F@us.ibm.com>
References: <cover.1305846412.git.mst@redhat.com>
	<OF0EFA7BA9.BB2C2860-ON6525789C.0053EE3A-6525789C.005513CC@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5190291678454274555=="
Cc: habanero@linux.vnet.ibm.com, lguest@lists.ozlabs.org, kvm@vger.kernel.org,
        Carsten Otte <cotte@de.ibm.com>, linux-s390@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Steve Dobbelstein <steved@us.ibm.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <OF0EFA7BA9.BB2C2860-ON6525789C.0053EE3A-6525789C.005513CC@in.ibm.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============5190291678454274555==
Content-type: multipart/related;
	Boundary="0__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C"

--0__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C
Content-type: multipart/alternative;
	Boundary="1__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C"

--1__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable


Hello KK,

	Could you please try TCP_RRs as well?

Thanks
Shirley


                                                                       =
    
             Krishna Kumar2                                            =
    
             <krkumar2@in.ibm.                                         =
    
             com>                                                      =
 To 
                                       "Michael S. Tsirkin"            =
    
             05/26/2011 08:32          <mst@redhat.com>                =
    
             AM                                                        =
 cc 
                                       Christian Borntraeger           =
    
                                       <borntraeger@de.ibm.com>, Carste=
n   
                                       Otte <cotte@de.ibm.com>,        =
    
                                       habanero@linux.vnet.ibm.com, Hei=
ko  
                                       Carstens                        =
    
                                       <heiko.carstens@de.ibm.com>,    =
    
                                       kvm@vger.kernel.org,            =
    
                                       lguest@lists.ozlabs.org,        =
    
                                       linux-kernel@vger.kernel.org,   =
    
                                       linux-s390@vger.kernel.org,     =
    
                                       linux390@de.ibm.com,            =
    
                                       netdev@vger.kernel.org, Rusty   =
    
                                       Russell <rusty@rustcorp.com.au>,=
    
                                       Martin Schwidefsky              =
    
                                       <schwidefsky@de.ibm.com>, Steve =
    
                                       Dobbelstein/Austin/IBM@IBMUS, To=
m   
                                       Lendacky <tahm@linux.vnet.ibm.co=
m>, 
                                       virtualization@lists.linux-found=
ati 
                                       on.org, Shirley                 =
    
                                       Ma/Beaverton/IBM@IBMUS          =
    
                                                                   Subj=
ect 
                                       [PERF RESULTS] virtio and vhost-=
net 
                                       performance enhancements        =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/20/2011 04:40:07 AM:

> OK, here is the large patchset that implements the virtio spec update=

> that I sent earlier (the spec itself needs a minor update, will send
> that out too next week, but I think we are on the same page here
> already). It supercedes the PUBLISH_USED_IDX patches I sent
> out earlier.

I was able to get this tested by applying the v2 patches
to git-next tree (somehow MST's git tree hung on my guest
which never got resolved). Testing was from Guest -> Remote
node, using an ixgbe 10g card. The test results are
*excellent* (table: #netperf sesssions, BW% improvement,
SD% improvement, CPU% improvement):

___________________________________
           512 byte I/O
#     BW%     SD%      CPU%
____________________________________
1     151.6   -65.1    -10.7
2     180.6   -66.6    -6.4
4     15.5    -35.8    -26.1
8     1.8     -28.4    -26.7
16    3.1     -29.0    -26.5
32    1.1     -27.4    -27.5
64    3.8     -30.9    -26.7
96    5.4     -21.7    -24.2
128   5.7     -24.4    -25.5
____________________________________
BW: 16.6%   SD: -24.6%    CPU: -25.5%


____________________________________
            1K I/O
#     BW%     SD%      CPU%
____________________________________
1     233.9   -76.5    -18.0
2     112.2   -64.0    -23.2
4     9.2     -31.6    -26.1
8    -1.7     -26.8    -30.3
16    3.5     -31.5    -30.6
32    4.8     -25.2    -30.5
64    5.7     -31.0    -28.9
96    5.3     -32.2    -31.7
128   4.6     -38.2    -33.6
____________________________________
BW: 16.4%   SD: -35.%    CPU: -31.5%


____________________________________
             16K I/O
#     BW%     SD%      CPU%
____________________________________
1     18.8    -27.2    -18.3
2     14.8    -36.7    -27.7
4     12.7    -45.2    -38.1
8     4.4     -56.4    -54.4
16    4.8     -38.3    -36.1
32    0        78.0     79.2
64    3.8     -38.1    -37.5
96    7.3     -35.2    -31.1
128   3.4     -31.1    -32.1
____________________________________
BW: 7.6%   SD: -30.1%   CPU: -23.7%


I plan to run some more tests tomorrow. Please let
me know if any other scenario will help.

Thanks,

- KK

=

--1__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Hello KK,<br>
<br>
	Could you please try TCP_RRs as well?<br>
<br>
Thanks<br>
Shirley <br>
<br>
<img width=3D"16" height=3D"16" src=3D"cid:1__=3D08BBF20FDFC5BD1C8f9e8a=
93df938@us.ibm.com" border=3D"0" alt=3D"Inactive hide details for Krish=
na Kumar2 ---05/26/2011 08:30:08 AM---&quot;Michael S. Tsirkin&quot; &l=
t;mst@redhat.com&gt; wrote on 05/20/2011 "><font color=3D"#424282">Kris=
hna Kumar2 ---05/26/2011 08:30:08 AM---&quot;Michael S. Tsirkin&quot; &=
lt;mst@redhat.com&gt; wrote on 05/20/2011 04:40:07 AM:</font><br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:2__=3D08BBF20F=
DFC5BD1C8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " widt=
h=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">Krishna Kumar2 &lt;krkumar2@in.ibm.com&gt;</fon=
t></b><font size=3D"2"> </font>
<p><font size=3D"2">05/26/2011 08:32 AM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%"><img width=3D"58" height=3D"1" src=3D=
"cid:3__=3D08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D08BBF20FDFC5BD1C8f=
9e8a93df938@us.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">&quot;Michael S. Tsirkin&quot; &lt;mst@redhat.com&gt;<=
/font></td></tr>

<tr valign=3D"top"><td width=3D"1%"><img width=3D"58" height=3D"1" src=3D=
"cid:3__=3D08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D08BBF20FDFC5BD1C8f=
9e8a93df938@us.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Christian Borntraeger &lt;borntraeger@de.ibm.com&gt;, =
Carsten Otte &lt;cotte@de.ibm.com&gt;, habanero@linux.vnet.ibm.com, Hei=
ko Carstens &lt;heiko.carstens@de.ibm.com&gt;, kvm@vger.kernel.org, lgu=
est@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.ker=
nel.org, linux390@de.ibm.com, netdev@vger.kernel.org, Rusty Russell &lt=
;rusty@rustcorp.com.au&gt;, Martin Schwidefsky &lt;schwidefsky@de.ibm.c=
om&gt;, Steve Dobbelstein/Austin/IBM@IBMUS, Tom Lendacky &lt;tahm@linux=
.vnet.ibm.com&gt;, virtualization@lists.linux-foundation.org, Shirley M=
a/Beaverton/IBM@IBMUS</font></td></tr>

<tr valign=3D"top"><td width=3D"1%"><img width=3D"58" height=3D"1" src=3D=
"cid:3__=3D08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D08BBF20FDFC5B=
D1C8f9e8a93df938@us.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">[PERF RESULTS] virtio and vhost-net performance enhanc=
ements</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img width=3D"1" height=3D"1" src=3D=
"cid:3__=3D08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""></td><td width=3D"336"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D=
08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com" border=3D"0" alt=3D""></td></=
tr>
</table>
</td></tr>
</table>
<br>
<tt>&quot;Michael S. Tsirkin&quot; &lt;mst@redhat.com&gt; wrote on 05/2=
0/2011 04:40:07 AM:<br>
<br>
&gt; OK, here is the large patchset that implements the virtio spec upd=
ate<br>
&gt; that I sent earlier (the spec itself needs a minor update, will se=
nd<br>
&gt; that out too next week, but I think we are on the same page here<b=
r>
&gt; already). It supercedes the PUBLISH_USED_IDX patches I sent<br>
&gt; out earlier.<br>
<br>
I was able to get this tested by applying the v2 patches<br>
to git-next tree (somehow MST's git tree hung on my guest<br>
which never got resolved). Testing was from Guest -&gt; Remote<br>
node, using an ixgbe 10g card. The test results are<br>
*excellent* (table: #netperf sesssions, BW% improvement,<br>
SD% improvement, CPU% improvement):<br>
<br>
___________________________________<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 512 byte I/O<br>
# &nbsp; &nbsp; BW% &nbsp; &nbsp; SD% &nbsp; &nbsp; &nbsp;CPU%<br>
____________________________________<br>
1 &nbsp; &nbsp; 151.6 &nbsp; -65.1 &nbsp; &nbsp;-10.7<br>
2 &nbsp; &nbsp; 180.6 &nbsp; -66.6 &nbsp; &nbsp;-6.4<br>
4 &nbsp; &nbsp; 15.5 &nbsp; &nbsp;-35.8 &nbsp; &nbsp;-26.1<br>
8 &nbsp; &nbsp; 1.8 &nbsp; &nbsp; -28.4 &nbsp; &nbsp;-26.7<br>
16 &nbsp; &nbsp;3.1 &nbsp; &nbsp; -29.0 &nbsp; &nbsp;-26.5<br>
32 &nbsp; &nbsp;1.1 &nbsp; &nbsp; -27.4 &nbsp; &nbsp;-27.5<br>
64 &nbsp; &nbsp;3.8 &nbsp; &nbsp; -30.9 &nbsp; &nbsp;-26.7<br>
96 &nbsp; &nbsp;5.4 &nbsp; &nbsp; -21.7 &nbsp; &nbsp;-24.2<br>
128 &nbsp; 5.7 &nbsp; &nbsp; -24.4 &nbsp; &nbsp;-25.5<br>
____________________________________<br>
BW: 16.6% &nbsp; SD: -24.6% &nbsp; &nbsp;CPU: -25.5%<br>
<br>
<br>
____________________________________<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;1K I/O<br>
# &nbsp; &nbsp; BW% &nbsp; &nbsp; SD% &nbsp; &nbsp; &nbsp;CPU%<br>
____________________________________<br>
1 &nbsp; &nbsp; 233.9 &nbsp; -76.5 &nbsp; &nbsp;-18.0<br>
2 &nbsp; &nbsp; 112.2 &nbsp; -64.0 &nbsp; &nbsp;-23.2<br>
4 &nbsp; &nbsp; 9.2 &nbsp; &nbsp; -31.6 &nbsp; &nbsp;-26.1<br>
8 &nbsp; &nbsp;-1.7 &nbsp; &nbsp; -26.8 &nbsp; &nbsp;-30.3<br>
16 &nbsp; &nbsp;3.5 &nbsp; &nbsp; -31.5 &nbsp; &nbsp;-30.6<br>
32 &nbsp; &nbsp;4.8 &nbsp; &nbsp; -25.2 &nbsp; &nbsp;-30.5<br>
64 &nbsp; &nbsp;5.7 &nbsp; &nbsp; -31.0 &nbsp; &nbsp;-28.9<br>
96 &nbsp; &nbsp;5.3 &nbsp; &nbsp; -32.2 &nbsp; &nbsp;-31.7<br>
128 &nbsp; 4.6 &nbsp; &nbsp; -38.2 &nbsp; &nbsp;-33.6<br>
____________________________________<br>
BW: 16.4% &nbsp; SD: -35.% &nbsp; &nbsp;CPU: -31.5%<br>
<br>
<br>
____________________________________<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 16K I/O<br>
# &nbsp; &nbsp; BW% &nbsp; &nbsp; SD% &nbsp; &nbsp; &nbsp;CPU%<br>
____________________________________<br>
1 &nbsp; &nbsp; 18.8 &nbsp; &nbsp;-27.2 &nbsp; &nbsp;-18.3<br>
2 &nbsp; &nbsp; 14.8 &nbsp; &nbsp;-36.7 &nbsp; &nbsp;-27.7<br>
4 &nbsp; &nbsp; 12.7 &nbsp; &nbsp;-45.2 &nbsp; &nbsp;-38.1<br>
8 &nbsp; &nbsp; 4.4 &nbsp; &nbsp; -56.4 &nbsp; &nbsp;-54.4<br>
16 &nbsp; &nbsp;4.8 &nbsp; &nbsp; -38.3 &nbsp; &nbsp;-36.1<br>
32 &nbsp; &nbsp;0 &nbsp; &nbsp; &nbsp; &nbsp;78.0 &nbsp; &nbsp; 79.2<br=
>
64 &nbsp; &nbsp;3.8 &nbsp; &nbsp; -38.1 &nbsp; &nbsp;-37.5<br>
96 &nbsp; &nbsp;7.3 &nbsp; &nbsp; -35.2 &nbsp; &nbsp;-31.1<br>
128 &nbsp; 3.4 &nbsp; &nbsp; -31.1 &nbsp; &nbsp;-32.1<br>
____________________________________<br>
BW: 7.6% &nbsp; SD: -30.1% &nbsp; CPU: -23.7%<br>
<br>
<br>
I plan to run some more tests tomorrow. Please let<br>
me know if any other scenario will help.<br>
<br>
Thanks,<br>
<br>
- KK<br>
<br>
</tt><br>
</body></html>=


--1__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C--


--0__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <1__=08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C
Content-type: image/gif;
	name="pic17152.gif"
Content-Disposition: inline; filename="pic17152.gif"
Content-ID: <2__=08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com>
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

--0__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <3__=08BBF20FDFC5BD1C8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=08BBF20FDFC5BD1C8f9e8a93df938690918c08BBF20FDFC5BD1C--


--===============5190291678454274555==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/virtualization
--===============5190291678454274555==--
