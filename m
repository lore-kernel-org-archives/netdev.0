From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen
Date: Tue, 7 Apr 2015 18:58:19 +0100
Message-ID: <21796.6843.983774.271495@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ian Jackson <Ian.Jackson@eu.citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:64267 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbbDGSxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 14:53:13 -0400
In-Reply-To: <1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> On Tue, 2015-04-07 at 16:12 +0100, Ian Jackson wrote:
> > The symptom is a very high level of packet loss: around 25-30% (as
> > seen in `ping').  There don't seem to be any untoward-looking kernel
> > messages.  The lost packets get added to the `errors' counter shown in
> > ifconfig. 
> 
> Please provide the output of "ethtool -S" which has a better breakdown
> of the error counters.  Thanks.

root@bedbug:~# ethtool -S eth0 | grep -v ': 0$'
NIC statistics:
     rx_octets: 793954
     rx_ucast_packets: 342
     rx_mcast_packets: 197
     rx_bcast_packets: 11049
     tx_octets: 59093
     tx_ucast_packets: 396
     tx_mcast_packets: 8
     tx_bcast_packets: 4
root@bedbug:~# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:16012 errors:0 dropped:0 overruns:0 frame:0
          TX packets:459 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1090543 (1.0 MiB)  TX bytes:64575 (63.0 KiB)
          Interrupt:17 

root@bedbug:~# 

And:

--- bedbug.cam.xci-test.com ping statistics ---
120 packets transmitted, 90 received, 25% packet loss, time 119354ms
rtt min/avg/max/mdev = 0.294/0.459/0.844/0.073 ms


Evidently on this particular kernel, the error counters are _not_
increasing, contrary to what I said before.  I confess that I didn't
keep a record of on which particular machine and kernel I observed the
error count increasing.

If it would help I could try to check various other machines and/or
other kernels to see if I can get one of them to display the error
counter behaviour.


I'm about to try the experiment suggested by Konrad.

Thanks,
Ian.
