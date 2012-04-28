From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2:  fix receive length error in mixed non-VLAN/VLAN
 traffic
Date: Fri, 27 Apr 2012 20:05:36 -0700
Message-ID: <20120427200536.6df2619e@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120427134127.6d536a96@nehalam.linuxnetplumber.net>
	<20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
	<4F9B2641.9070209@linuxsystems.it>
	<20120427200310.60325fb1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36143 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753497Ab2D1DFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 23:05:40 -0400
In-Reply-To: <20120427200310.60325fb1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Apr 2012 20:03:10 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> Bug: The VLAN bit of the MAC RX Status Word is unreliable in several older
> supported chips. Sometimes the VLAN bit is not set for valid VLAN packets
> and also sometimes the VLAN bit is set for non-VLAN packets that came after
> a VLAN packet. This results in a receive length error when VLAN hardware
> tagging is enabled.
> 
> Fix: The driver uses only VLAN information included in VLAN status list elements,
> that signals that the VLAN tag field is valid. It must ignore the VLAN bit in the
> MAC RX Status Word. An additional variable set when evaluating the VLAN opcodes
> is used to indicate that the received packet is a VLAN packet and a packet length
> correction (subtraction of VLAN header length) must be done.
> 
> This is an alternative to Mirko's patch that relies on the new method of
> encoding VLAN tag, and therefore means extra code can be removed.
> 
> Testing: Tested with regular and VLAN traffic on 88E8056, but this chip
> does not have the bug, just proves that the alternative method of handling
> VLAN tag will work.
> 
> Reported-by: Mirko Lindner <mlindner@marvell.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 

This doesn't work. Furthur testing just crapped out with lots
of rx length errors in mixed vlan/non-vlan traffic case.
