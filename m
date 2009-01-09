From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Fri, 9 Jan 2009 09:39:44 -0000 (WET)
Message-ID: <1052.192.168.1.3.1231493984.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <20090108094231.GD4496@ff.dom.local>
    <20090108095403.GE4496@ff.dom.local>
    <20090108100614.GA5418@ff.dom.local>
    <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
    <20090108110430.GB5493@ff.dom.local>
    <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt>
    <20090108135927.GC5493@ff.dom.local>
    <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt>
    <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
    <20090109072452.GA4605@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly07.isp.novis.pt ([195.23.133.217]:53492 "EHLO
	mailrly07.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982AbZAIJjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:39:20 -0500
In-Reply-To: <20090109072452.GA4605@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Going to.
But tell me, for this, all 3 params should be disabled, correct?

> On Thu, Jan 08, 2009 at 05:27:31PM -0000, mysql.jorge@decimal.pt wrote:
>> I asume there's some issue with the NIC Driver os the kernel modules
>> with
>> the 1000Mbit NIC's? am i correct?
>
> In this case the issue is packet schedulers usually don't work with
> gso/tso enabled, at least without some tweaking with mtu. Some qdisc
> get inacurrate, others (like tbf) can drop too big packets (have a
> look at "dropped" stats).
>
> BTW, Jorge, since my tries to Cc bugzilla failed, please add some
> comment to your bug report (I guess it could be closed too).
>
> Thanks
> Jarek P.
>
>>
>>
>> > An active connection when running this commands:
>> > (now it seams to work, the 200Kbit i defined, are gaving me
>> 22.5/23Kbyte
>> > /sec)
>> >
>> > Did you catch it?
>> >
>> >
>> > lira:~# ethtool -k eth0
>> > Offload parameters for eth0:
>> > Cannot get device flags: Operation not supported
>> > rx-checksumming: on
>> > tx-checksumming: on
>> > scatter-gather: off
>> > tcp segmentation offload: off
>> > udp fragmentation offload: off
>> > generic segmentation offload: off
>> > large receive offload: off
>> > lira:~# tc -s qdisc show dev eth0
>> > qdisc cbq 1: root rate 12500000bps (bounded,isolated) prio no-transmit
>> >  Sent 5336353 bytes 5737 pkts (dropped 16, overlimits 1382)
>> >  backlog 8p
>> >   borrowed 0 overactions 0 avgidle 78 undertime 0
>> >
>> >  qdisc tbf 1280: parent 1:1280 rate 25000bps burst 10Kb lat 209.7ms
>> >  Sent 441812 bytes 310 pkts (dropped 16, overlimits 2215)
>> >  backlog 8p
>> >
>> > lira:~# tc -s class show dev eth0
>> > class cbq 1: root rate 12500000bps (bounded,isolated) prio no-transmit
>> >  Sent 5128779 bytes 5827 pkts (dropped 0, overlimits 0)
>> >   borrowed 0 overactions 0 avgidle 78 undertime 0
>> > class cbq 1:1280 parent 1: leaf 1280: rate 25000bps (bounded,isolated)
>> > prio 5
>> >  Sent 811784 bytes 568 pkts (dropped 22, overlimits 0)
>> >  backlog 9p
>> >   borrowed 0 overactions 0 avgidle 4507 undertime 0
>> > class tbf 1280:1 parent 1280: [UNKNOWN]
>> >  Sent 0 bytes 0 pkts (dropped 0, overlimits 0)
>> >
>> >
>> >
>> >
>> >
>> >> Could you try to check this with scatter-gather and tcp segmentation
>> >> offload off too? If there is no difference please send the stats
>> >> again both for working and non-working case.
>> >>
>> >> Thanks,
>> >> Jarek P.
>> >>
>> >
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >
>>
>>
>


