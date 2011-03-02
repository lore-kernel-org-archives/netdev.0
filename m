From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Tue, 1 Mar 2011 23:07:54 -0800
Message-ID: <20110301230754.5ef4ab35@nehalam>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	<alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	<1298793252.8726.45.camel@edumazet-laptop>
	<AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	<20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	<AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
	<cbb9e1113901f1a324359b6ed3f1a611@localhost>
	<AANLkTikje6rvjSfEA3CvUjdgFwzk-SBZDdO5kQvi6LZy@mail.gmail.com>
	<AANLkTin_jY_J7tJseMLVmrQVVRezOVQTGCgB_6tefgXJ@mail.gmail.com>
	<alpine.DEB.1.10.1103010137400.7942@uplift.swm.pp.se>
	<20110301222531.24832a93@nehalam>
	<alpine.DEB.1.10.1103020736260.7942@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Heffner <johnwheffner@gmail.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Albert Cahalan <acahalan@gmail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51156 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853Ab1CBHH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 02:07:58 -0500
In-Reply-To: <alpine.DEB.1.10.1103020736260.7942@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Mar 2011 07:41:30 +0100 (CET)
Mikael Abrahamsson <swmike@swm.pp.se> wrote:

> On Tue, 1 Mar 2011, Stephen Hemminger wrote:
> 
> > It is possible to build an equivalent to WRED out existing GRED queuing
> > discipline but it does require a lot of tc knowledge to get right.  
> 
> To me who has worked with cisco routers for 10+ years and who is used to 
> the different variants Cisco use, tc is just weird. It must come from a 
> completely different school of thinking compared to what router people are 
> used to, because I have tried and failed twice to do anything sensible 
> with it.

Vyatta has scripting that handles all that:

vyatta@napa:~$ configure
[edit]
yatta@napa# set traffic-policy random-detect MyWFQ bandwidth 1gbps
[edit]
vyatta@napa# set interfaces ethernet eth0 traffic-policy out MyWFQ 
[edit]
vyatta@napa# commit
[edit]
vyatta@napa# exit
vyatta@napa:~$ show queueing ethernet eth0

eth0 Queueing:
Class      Policy               Sent     Rate  Dropped Overlimit  Backlog
root       weighted-random     16550                 0        0        0

vyatta@napa:~$ /sbin/tc qdisc show dev eth0
qdisc dsmark 1: root refcnt 2 indices 0x0008 set_tc_index 
qdisc gred 2: parent 1: 
 DP:0 (prio 8) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 82 (bytes 9540)  ewma 3 Plog 17 Scell_log 3
 DP:1 (prio 7) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 0 (bytes 0)  ewma 2 Plog 17 Scell_log 2
 DP:2 (prio 6) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 0 (bytes 0)  ewma 2 Plog 17 Scell_log 2
 DP:3 (prio 5) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 0 (bytes 0)  ewma 2 Plog 16 Scell_log 2
 DP:4 (prio 4) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 0 (bytes 0)  ewma 2 Plog 16 Scell_log 2
 DP:5 (prio 3) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 0 (bytes 0)  ewma 2 Plog 16 Scell_log 2
 DP:6 (prio 2) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 0 (bytes 0)  ewma 2 Plog 15 Scell_log 2
 DP:7 (prio 1) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 0 (bytes 0)  ewma 1 Plog 15 Scell_log 1



QoS on Cisco has different/other problems mostly because various groups
tried to fix the QoS problem over time and never got it quite right.
Also WRED is not default on faster links because it can't be done
fast enough.

