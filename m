From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: FW: loop on reset adapter with ixgbe
Date: Tue, 26 Nov 2013 19:03:41 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866466FD8A499@ORSMSX110.amr.corp.intel.com>
References: <20131120182524.GC16953@gandi.net>
 <F6FB0E698C9B3143BDF729DF222866466FD88724@ORSMSX110.amr.corp.intel.com>
 <20131126130410.GD2849@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Potenza, Leonardo" <leonardo.potenza@intel.com>
To: William Dauchy <william@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54024 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754496Ab3KZTDo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 14:03:44 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Skidmore, Donald C 
Sent: Tuesday, November 26, 2013 11:00 AM
To: 'William Dauchy'
Cc: netdev@vger.kernel.org; Keller, Jacob E; Fastabend, John R; Tantilov, Emil S; Potenza, Leonardo
Subject: RE: loop on reset adapter with ixgbe


Hey William,

A quick why to get the device ID would be to:

First get the PCIe bus address from "ethtool -I <port>"

[root@dcsworkstation src]# ethtool -i p258p1
driver: ixgbe
version: 3.11.33-k
firmware-version: 0x18eb0001
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

Then use that address to find the device ID:

[root@dcsworkstation src]# lspci -ns 0000:05:00.0
05:00.0 0200: 8086:10fb (rev 01)


As for the FW version I'm concerned that yours might not be correct from the output you sent me earlier.

> ethtool info:
> driver: ixgbe
> version: 3.8.21-k
> firmware-version: 0x00000000

This doesn't look correct to me I will poke our FW folks to verify.  It may be worthwhile to dump the FW and send it to me (i.e. ethtool -eeprom-dump).

Thanks,
-Don

p.s. I'm about to be out of the office until Tuesday of next week and am not sure I'll be able to get to my email so I might be slow in a reply.  :(




> -----Original Message-----
> From: William Dauchy [mailto:william@gandi.net]
> Sent: Tuesday, November 26, 2013 5:04 AM
> To: Skidmore, Donald C
> Cc: William Dauchy; netdev@vger.kernel.org; Keller, Jacob E; Fastabend,
> John R; Tantilov, Emil S; Potenza, Leonardo
> Subject: Re: loop on reset adapter with ixgbe
> 
> On Nov20 18:58, Skidmore, Donald C wrote:
> > I also just noticed your firmware looks in correct.  What is the DevID for
> your device?
> 
> might be a stupid question, but which id are you talking about? How can I get
> it?
> 
> > Likewise do you have another NIC and if so could you check it's firmware-
> version?
> 
> I have some NIC with the same firmware without any problem.
> 
> Regards,
> --
> William
