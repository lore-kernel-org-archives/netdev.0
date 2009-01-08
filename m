From: mysql.jorge@decimal.pt
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!    
       2.6.28
Date: Thu, 8 Jan 2009 17:27:31 -0000 (WET)
Message-ID: <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <20090108094231.GD4496@ff.dom.local>
    <20090108095403.GE4496@ff.dom.local>
    <20090108100614.GA5418@ff.dom.local>
    <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
    <20090108110430.GB5493@ff.dom.local>
    <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt>
    <20090108135927.GC5493@ff.dom.local>
    <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly06.isp.novis.pt ([195.23.133.216]:54571 "EHLO
	mailrly06.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbZAHR1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 12:27:12 -0500
In-Reply-To: <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I asume there's some issue with the NIC Driver os the kernel modules with
the 1000Mbit NIC's? am i correct?


> An active connection when running this commands:
> (now it seams to work, the 200Kbit i defined, are gaving me 22.5/23Kbyte
> /sec)
>
> Did you catch it?
>
>
> lira:~# ethtool -k eth0
> Offload parameters for eth0:
> Cannot get device flags: Operation not supported
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off
> large receive offload: off
> lira:~# tc -s qdisc show dev eth0
> qdisc cbq 1: root rate 12500000bps (bounded,isolated) prio no-transmit
>  Sent 5336353 bytes 5737 pkts (dropped 16, overlimits 1382)
>  backlog 8p
>   borrowed 0 overactions 0 avgidle 78 undertime 0
>
>  qdisc tbf 1280: parent 1:1280 rate 25000bps burst 10Kb lat 209.7ms
>  Sent 441812 bytes 310 pkts (dropped 16, overlimits 2215)
>  backlog 8p
>
> lira:~# tc -s class show dev eth0
> class cbq 1: root rate 12500000bps (bounded,isolated) prio no-transmit
>  Sent 5128779 bytes 5827 pkts (dropped 0, overlimits 0)
>   borrowed 0 overactions 0 avgidle 78 undertime 0
> class cbq 1:1280 parent 1: leaf 1280: rate 25000bps (bounded,isolated)
> prio 5
>  Sent 811784 bytes 568 pkts (dropped 22, overlimits 0)
>  backlog 9p
>   borrowed 0 overactions 0 avgidle 4507 undertime 0
> class tbf 1280:1 parent 1280: [UNKNOWN]
>  Sent 0 bytes 0 pkts (dropped 0, overlimits 0)
>
>
>
>
>
>> Could you try to check this with scatter-gather and tcp segmentation
>> offload off too? If there is no difference please send the stats
>> again both for working and non-working case.
>>
>> Thanks,
>> Jarek P.
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


