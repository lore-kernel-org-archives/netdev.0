From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [RFC] bnx2x: Insane RX rings
Date: Thu, 09 Sep 2010 23:21:01 +0200
Message-ID: <4C894FBD.2020109@ans.pl>
References: <1284065105.4782.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:42136 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658Ab0IIVVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 17:21:08 -0400
In-Reply-To: <1284065105.4782.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-09 22:45, Eric Dumazet wrote:
> So I have a small dev machine, 4GB of ram,
> a dual E5540 cpu (quad core, 2 threads per core),
> so a total of 16 threads.
>
> Two ethernet ports, eth0 and eth1,
>
> 02:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM577=
11E 10Gigabit PCIe
> 02:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM577=
11E 10Gigabit PCIe
>
> bnx2x 0000:02:00.0: eth0: using MSI-X  IRQs: sp 68  fp[0] 69 ... fp[1=
5] 84
> bnx2x 0000:02:00.1: eth1: using MSI-X  IRQs: sp 85  fp[0] 86 ... fp[1=
5] 101
>
>
> Default configuration :
>
> ethtool -g eth0
> Ring parameters for eth0:
> Pre-set maximums:
> RX:		4078
> RX Mini:	0
> RX Jumbo:	0
> TX:		4078
> Current hardware settings:
> RX:		4078
> RX Mini:	0
> RX Jumbo:	0
> TX:		4078
>
> Problem is : With 16 RX queues per device , thats 4078*16*2Kbytes per
> ethernet port.
>
> Total :
>
> skbuff_head_cache 130747 131025    256   15    1 : tunables  120   60=
    8 : slabdata   8735   8735     40
> size-2048         130866 130888   2048    2    1 : tunables   24   12=
    8 : slabdata  65444  65444     28
>
> Thats about 300 Mbytes of memory, just in case some network trafic wi=
ll occur.
>
> Lets do something about that ?

Yep, it is ~8MB per queue, not so much alone, but a lot together. For=20
this reason I use something like bnx2.num_queues=3D2 on servers where I=
=20
don't need much CPU power for network workload.

Best regards,

			Krzysztof Ol=C4=99dzki
