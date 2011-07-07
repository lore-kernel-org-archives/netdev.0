From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: RFT: virtio_net: limit xmit polling
Date: Thu, 07 Jul 2011 06:24:22 -0700
Message-ID: <CA3B0196.2D7A9%roprabhu@cisco.com>
References: <20110629084206.GA14627@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1957387557649889097=="
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, habanero@linux.vnet.ibm.com,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, Carsten Otte <cotte@de.ibm.com>,
        linux-s390@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20110629084206.GA14627@redhat.com>
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

> This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

--===============1957387557649889097==
Content-type: multipart/alternative;
	boundary="B_3392864662_8981458"

> This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

--B_3392864662_8981458
Content-type: text/plain;
	charset="US-ASCII"
Content-transfer-encoding: 7bit




On 6/29/11 1:42 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
>> >roprabhu, Tom,
>> >
>> >Thanks very much for the testing. So on the first glance
>> >one seems to see a significant performance gain in V0 here,
>> >and a slightly less significant in V2, with V1
>> >being worse than base. But I'm afraid that's not the
>> >whole story, and we'll need to work some more to
>> >know what really goes on, please see below.
>> >
>> >
>> >Some comments on the results: I found out that V0 because of mistake
>> >on my part was actually almost identical to base.
>> >I pushed out virtio-net-limit-xmit-polling/v1a instead that
>> >actually does what I intended to check. However,
>> >the fact we get such a huge distribution in the results by Tom
>> >most likely means that the noise factor is very large.
>> >
>> >
>> >From my experience one way to get stable results is to
>> >divide the throughput by the host CPU utilization
>> >(measured by something like mpstat).
>> >Sometimes throughput doesn't increase (e.g. guest-host)
>> >by CPU utilization does decrease. So it's interesting.
>> >
>> >
>> >Another issue is that we are trying to improve the latency
>> >of a busy queue here. However STREAM/MAERTS tests ignore the latency
>> >(more or less) while TCP_RR by default runs a single packet per queue.
>> >Without arguing about whether these are practically interesting
>> >workloads, these results are thus unlikely to be significantly affected
>> >by the optimization in question.
>> >
>> >What we are interested in, thus, is either TCP_RR with a -b flag
>> >(configure with  --enable-burst) or multiple concurrent
>> >TCP_RRs.
> 
> ok sounds good. I am testing your v1a patch. Will try to get some results out
> end of this week. Thanks.
> 


--B_3392864662_8981458
Content-type: text/html;
	charset="US-ASCII"
Content-transfer-encoding: quoted-printable

<HTML>
<HEAD>
<TITLE>Re: RFT: virtio_net: limit xmit polling</TITLE>
</HEAD>
<BODY>
<FONT FACE=3D"Calibri, Verdana, Helvetica, Arial"><SPAN STYLE=3D'font-size:11pt=
'><BR>
<BR>
<BR>
On 6/29/11 1:42 AM, &quot;Michael S. Tsirkin&quot; &lt;<a href=3D"mst@redhat.=
com">mst@redhat.com</a>&gt; wrote:<BR>
</SPAN></FONT><BLOCKQUOTE><FONT FACE=3D"Calibri, Verdana, Helvetica, Arial"><=
SPAN STYLE=3D'font-size:11pt'><BR>
&gt;roprabhu, Tom,<BR>
&gt;<BR>
&gt;Thanks very much for the testing. So on the first glance<BR>
&gt;one seems to see a significant performance gain in V0 here,<BR>
&gt;and a slightly less significant in V2, with V1<BR>
&gt;being worse than base. But I'm afraid that's not the<BR>
&gt;whole story, and we'll need to work some more to<BR>
&gt;know what really goes on, please see below.<BR>
&gt;<BR>
&gt;<BR>
&gt;Some comments on the results: I found out that V0 because of mistake<BR=
>
&gt;on my part was actually almost identical to base.<BR>
&gt;I pushed out virtio-net-limit-xmit-polling/v1a instead that<BR>
&gt;actually does what I intended to check. However,<BR>
&gt;the fact we get such a huge distribution in the results by Tom<BR>
&gt;most likely means that the noise factor is very large.<BR>
&gt;<BR>
&gt;<BR>
&gt;From my experience one way to get stable results is to<BR>
&gt;divide the throughput by the host CPU utilization<BR>
&gt;(measured by something like mpstat).<BR>
&gt;Sometimes throughput doesn't increase (e.g. guest-host)<BR>
&gt;by CPU utilization does decrease. So it's interesting.<BR>
&gt;<BR>
&gt;<BR>
&gt;Another issue is that we are trying to improve the latency<BR>
&gt;of a busy queue here. However STREAM/MAERTS tests ignore the latency<BR=
>
&gt;(more or less) while TCP_RR by default runs a single packet per queue.<=
BR>
&gt;Without arguing about whether these are practically interesting<BR>
&gt;workloads, these results are thus unlikely to be significantly affected=
<BR>
&gt;by the optimization in question.<BR>
&gt;<BR>
&gt;What we are interested in, thus, is either TCP_RR with a -b flag<BR>
&gt;(configure with &nbsp;--enable-burst) or multiple concurrent<BR>
&gt;TCP_RRs.<BR>
<BR>
ok sounds good. I am testing your v1a patch. Will try to get some results o=
ut end of this week. Thanks.<BR>
<BR>
</SPAN></FONT></BLOCKQUOTE>
</BODY>
</HTML>


--B_3392864662_8981458--


--===============1957387557649889097==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/virtualization
--===============1957387557649889097==--
