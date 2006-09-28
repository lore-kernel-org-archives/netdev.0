From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Network problem with 2.6.18-mm1 ?
Date: Wed, 27 Sep 2006 19:02:17 -0700
Message-ID: <451B2D29.9040306@intel.com>
References: <20060928013724.GA22898@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15638 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S965191AbWI1CET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 22:04:19 -0400
To: Sukadev Bhattiprolu <sukadev@us.ibm.com>
In-Reply-To: <20060928013724.GA22898@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sukadev Bhattiprolu wrote:
> 
> I am unable to get networking to work with 2.6.18-mm1 on my system.
> 
> But 2.6.18 kernel on same system works fine. Here is some info about
> the system/debug attempts. Attached are the lspci output and config.
> 
> Appreciate any help. Please let me know if you need more info. 
> 
> Suka
> 
> System info:
> 
> 	x326, 2 CPU (AMD Opteron Processor 250)
> 
> Kernel info:
> 
> 	$ uname -a
> 	Linux elm3b166 2.6.18-mm1 #4 SMP PREEMPT Tue Sep 26 18:11:58 PDT 2006
> 	x86_64 GNU/Linux
> 
> 	Config tokens differing between the 2.6.18 kernel that works and
> 	the 2.6.18-mm1 that does not are:
> 
> 	Tokens in 2.6.18 but not in 2.6.18-mm1 config
> 
> 		CONFIG_SCSI_FC_ATTRS=y
> 		CONFIG_SCSI_SATA_SIL=y
> 		CONFIG_SCSI_SATA=y
> 
> 	Tokens in 2.6.18-mm1 but not in 2.6.18 config
> 
> 		CONFIG_PROC_SYSCTL=y
> 		CONFIG_SATA_SIL=y 
> 		CONFIG_ATA=y 
> 		CONFIG_ARCH_POPULATES_NODE_MAP=y
> 		CONFIG_CRYPTO_ALGAPI=y
> 		CONFIG_MICROCODE_OLD_INTERFACE=y
> 		CONFIG_BLOCK=y
> 		CONFIG_VIDEO_V4L1_COMPAT=y
> 		CONFIG_ZONE_DMA=y
> 		CONFIG_FB_DDC=y
> 
> 	All drivers compiled into kernel in both cases.
> 
> Debug info:
> 
> 	Checked hardware connections :-) 
> 	(Rebooting on 2.6.18 kernel works - consistently)
> 	
> 	$ ethtool -i eth0
> 		driver: e1000
> 		version: 7.2.7-k2
> 		firmware-version: N/A
> 
> 	$ ip addr
> 		seems fine (up, broadcasting etc)
> 
> 	$ ip -s link
> 		shows no errors/drops/overruns
> 
> 	$ ip route
> 		shows the correct gw
> 
> 	$ ethtool -S eth0
> 
> 		shows non-zero tx/rx packets/bytes but *rx_missed_errors*
> 		quite large (~138K) and increasing over time
> 
> 	$ ping <own-ip-addr>
> 		works fine
> 
> 	$ ping <gateway>
> 		no response.
> 
> 	$ tcpdump -i eth0 host <broken-host>
> 	
> 		while pinging gateway, tcpdump shows messages like:
> 
> 		18:03:45.936161 arp who-has <gateway> tell <broken-host>
> 
> (Config file and lspci output are attached)

how about dmesg? Perhaps it shows some valuable information.

also, since this is a networking problem, please include `ifconfig eth0` and the full 
output of `ethtool eth0` and `ethtool -S eth0`

Cheers,

Auke
