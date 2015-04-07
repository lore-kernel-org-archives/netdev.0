From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen
Date: Tue, 7 Apr 2015 19:13:31 +0100
Message-ID: <21796.7755.270785.292996@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59035 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbbDGTFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:05:19 -0400
In-Reply-To: <21796.6843.983774.271495@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Jackson writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> Evidently on this particular kernel, the error counters are _not_
> increasing, contrary to what I said before.  I confess that I didn't
> keep a record of on which particular machine and kernel I observed the
> error count increasing.
> 
> If it would help I could try to check various other machines and/or
> other kernels to see if I can get one of them to display the error
> counter behaviour.

I just realised that I didn't check xenbr0 as well as eth0:

root@bedbug:~# ifconfig xenbr0
xenbr0    Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
          inet addr:10.80.249.102  Bcast:10.80.251.255
          Mask:255.255.252.0
          inet6 addr: fe80::213:72ff:fe14:c051/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12296 errors:0 dropped:793 overruns:0 frame:0
          TX packets:437 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:618757 (604.2 KiB)  TX bytes:49084 (47.9 KiB)

root@bedbug:~# ethtool -S xenbr0 | grep -v ': 0$'
no stats available
root@bedbug:~#

The value for "dropped" increases steadily.  This particular box is on
a network with a lot of other stuff, so it will be constantly
receiving broadcasts of various kinds even when I am not trying to
address it directly.

Ian.
