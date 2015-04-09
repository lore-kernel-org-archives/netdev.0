From: Michael Chan <mchan@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 9 Apr 2015 11:26:55 -0700
Message-ID: <1428604015.5004.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	 <1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <21796.6843.983774.271495@mariner.uk.xensource.com>
	 <21796.7755.270785.292996@mariner.uk.xensource.com>
	 <1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1428448976.4720.15.camel@prashant>
	 <21797.13348.524963.29127@mariner.uk.xensource.com>
	 <1428543798.4720.20.camel@prashant>
	 <21798.24161.922394.539733@mariner.uk.xensource.com>
	 <1428595851.4720.22.camel@prashant>
	 <21798.44949.156680.399387@mariner.uk.xensource.com>
	 <21798.46590.928152.666550@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:3583 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbbDIS10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:27:26 -0400
In-Reply-To: <21798.46590.928152.666550@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 18:25 +0100, Ian Jackson wrote:
> root@bedbug:~# ethtool -S eth0 | grep -v ': 0$'
> NIC statistics:
>      rx_octets: 8196868
>      rx_ucast_packets: 633
>      rx_mcast_packets: 1
>      rx_bcast_packets: 123789
>      tx_octets: 42854
>      tx_ucast_packets: 9
>      tx_mcast_packets: 8
>      tx_bcast_packets: 603
> root@bedbug:~# ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
>           inet addr:10.80.249.102  Bcast:10.80.251.255
>           Mask:255.255.252.0
>           inet6 addr: fe80::213:72ff:fe14:c051/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:124774 errors:0 dropped:88921 overruns:0 frame:0
>           TX packets:620 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:8222158 (7.8 MiB)  TX bytes:42854 (41.8 KiB)
>           Interrupt:17 

The dropped counter reported by ifconfig is 2 counters combined:
rx_dropped + rx_missed_errors.  Since ethtool -S is not reporting any
rx_discards, all the drops should be caused by tg3_rx().  We can drop
because the descriptor shows error or we cannot allocate SKB.

Can you check to see if your kernel source has this tg3 patch applied?

tg3: Don't check undefined error bits in RXBD
d7b95315cc7f441418845a165ee56df723941487
> 
> 
