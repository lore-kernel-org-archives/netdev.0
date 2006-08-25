From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: [IPV6] Q: corrupt checksums when transferring data
Date: Fri, 25 Aug 2006 11:13:48 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5281CB69@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4357 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1030222AbWHYSPG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 14:15:06 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm enabling e1000 to offload IPv6 since the 2.6.18+ kernels support it.
The kernel I'm testing is 2.6.18-rc4.  

Everything with the hardware offload is working fine, but it appears
that the GSO code may not correctly segment frames sometimes for IPv6
traffic.
I did a tcpdump on both ends with all hardware offloading disabled
through ethtool.  Here is what I got, note the long frame and then the
retransmit.

Has this problem been addressed already?  I'll compile and test a couple
newer kernels, any suggested target patches or kernels would be
appreciated.

Sender:
=======
15:56:28.769034 bk1-6.33541 > lh2-6.12865: S 3200244805:3200244805(0)
win 5760 <mss 1440,sackOK,timestamp 64767859 0,nop,wscale 7>
15:56:28.769042 lh2-6.12865 > bk1-6.33541: S 1558653050:1558653050(0)
ack 3200244806 win 5712 <mss 1440,sackOK,timestamp 172654320
64767859,nop,wscale 7>
15:56:28.769102 bk1-6.33541 > lh2-6.12865: . ack 1 win 45
<nop,nop,timestamp 64767859 172654320>
15:56:28.769350 bk1-6.33541 > lh2-6.12865: P 1:257(256) ack 1 win 45
<nop,nop,timestamp 64767859 172654320>
15:56:28.769381 lh2-6.12865 > bk1-6.33541: . ack 257 win 53
<nop,nop,timestamp 172654320 64767859>
15:56:28.769731 lh2-6.12865 > bk1-6.33541: P 1:257(256) ack 257 win 53
<nop,nop,timestamp 172654320 64767859>
15:56:28.769851 bk1-6.33541 > lh2-6.12865: . ack 257 win 54
<nop,nop,timestamp 64767860 172654320>
15:56:28.769860 bk1-6.46315 > lh2-6.35704: S 3205139672:3205139672(0)
win 5760 <mss 1440,sackOK,timestamp 64767860 0,nop,wscale 7>
15:56:28.769873 lh2-6.35704 > bk1-6.46315: S 1557432368:1557432368(0)
ack 3205139673 win 5712 <mss 1440,sackOK,timestamp 172654320
64767860,nop,wscale 7>
15:56:28.769975 bk1-6.46315 > lh2-6.35704: . ack 1 win 45
<nop,nop,timestamp 64767860 172654320>
15:56:28.770009 lh2-6.35704 > bk1-6.46315: . 1:2857(2856) ack 1 win 45
<nop,nop,timestamp 172654320 64767860>
15:56:28.972354 lh2-6.35704 > bk1-6.46315: . 1:1429(1428) ack 1 win 45
<nop,nop,timestamp 172654371 64767860>
15:56:28.972478 bk1-6.46315 > lh2-6.35704: . ack 1429 win 68
<nop,nop,timestamp 64767910 172654371>
15:56:28.972493 lh2-6.35704 > bk1-6.46315: . 1429:2857(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.972602 bk1-6.46315 > lh2-6.35704: . ack 2857 win 90
<nop,nop,timestamp 64767910 172654371>
15:56:28.972611 lh2-6.35704 > bk1-6.46315: . 2857:4285(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.972727 bk1-6.46315 > lh2-6.35704: . ack 4285 win 112
<nop,nop,timestamp 64767910 172654371>
15:56:28.972735 lh2-6.35704 > bk1-6.46315: . 4285:5713(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.972742 lh2-6.35704 > bk1-6.46315: . 5713:7141(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.972853 bk1-6.46315 > lh2-6.35704: . ack 5713 win 135
<nop,nop,timestamp 64767910 172654371>
15:56:28.972862 lh2-6.35704 > bk1-6.46315: . 7141:8569(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.972868 lh2-6.35704 > bk1-6.46315: . 8569:9997(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>

Receiver:
=========
15:56:28.764058 bk1-6.33541 > lh2-6.12865: S 3200244805:3200244805(0)
win 5760 <mss 1440,sackOK,timestamp 64767859 0,nop,wscale 7>
15:56:28.764181 lh2-6.12865 > bk1-6.33541: S 1558653050:1558653050(0)
ack 3200244806 win 5712 <mss 1440,sackOK,timestamp 172654320
64767859,nop,wscale 7>
15:56:28.764205 bk1-6.33541 > lh2-6.12865: . ack 1 win 45
<nop,nop,timestamp 64767859 172654320>
15:56:28.764441 bk1-6.33541 > lh2-6.12865: P 1:257(256) ack 1 win 45
<nop,nop,timestamp 64767859 172654320>
15:56:28.764552 lh2-6.12865 > bk1-6.33541: . ack 257 win 53
<nop,nop,timestamp 172654320 64767859>
15:56:28.764926 lh2-6.12865 > bk1-6.33541: P 1:257(256) ack 257 win 53
<nop,nop,timestamp 172654320 64767859>
15:56:28.764936 bk1-6.33541 > lh2-6.12865: . ack 257 win 54
<nop,nop,timestamp 64767860 172654320>
15:56:28.764962 bk1-6.46315 > lh2-6.35704: S 3205139672:3205139672(0)
win 5760 <mss 1440,sackOK,timestamp 64767860 0,nop,wscale 7>
15:56:28.765052 lh2-6.35704 > bk1-6.46315: S 1557432368:1557432368(0)
ack 3205139673 win 5712 <mss 1440,sackOK,timestamp 172654320
64767860,nop,wscale 7>
15:56:28.765061 bk1-6.46315 > lh2-6.35704: . ack 1 win 45
<nop,nop,timestamp 64767860 172654320>
15:56:28.765300 lh2-6.35704 > bk1-6.46315: . 1:1429(1428) ack 1 win 45
<nop,nop,timestamp 172654320 64767860>
15:56:28.765306 lh2-6.35704 > bk1-6.46315: . 1429:2857(1428) ack 1 win
45 <nop,nop,timestamp 172654320 64767860>
15:56:28.967565 lh2-6.35704 > bk1-6.46315: . 1:1429(1428) ack 1 win 45
<nop,nop,timestamp 172654371 64767860>
15:56:28.967581 bk1-6.46315 > lh2-6.35704: . ack 1429 win 68
<nop,nop,timestamp 64767910 172654371>
15:56:28.967691 lh2-6.35704 > bk1-6.46315: . 1429:2857(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.967702 bk1-6.46315 > lh2-6.35704: . ack 2857 win 90
<nop,nop,timestamp 64767910 172654371>
15:56:28.967816 lh2-6.35704 > bk1-6.46315: . 2857:4285(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.967826 bk1-6.46315 > lh2-6.35704: . ack 4285 win 112
<nop,nop,timestamp 64767910 172654371>
15:56:28.967941 lh2-6.35704 > bk1-6.46315: . 4285:5713(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.967946 lh2-6.35704 > bk1-6.46315: . 5713:7141(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.967951 bk1-6.46315 > lh2-6.35704: . ack 5713 win 135
<nop,nop,timestamp 64767910 172654371>
15:56:28.967956 bk1-6.46315 > lh2-6.35704: . ack 7141 win 157
<nop,nop,timestamp 64767910 172654371>
15:56:28.968066 lh2-6.35704 > bk1-6.46315: . 7141:8569(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.968071 lh2-6.35704 > bk1-6.46315: . 8569:9997(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
15:56:28.968073 lh2-6.35704 > bk1-6.46315: P 9997:11425(1428) ack 1 win
45 <nop,nop,timestamp 172654371 64767910>
