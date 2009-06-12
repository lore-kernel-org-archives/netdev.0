From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver not advertising 1000mbit
Date: Fri, 12 Jun 2009 15:01:46 -0700
Message-ID: <1244844106.9225.92.camel@HP1>
References: <7e14b58794647ea1b1b0a644e14a11f6@localhost>
 <1244831838.9225.71.camel@HP1> <4A32CDE9.7020602@dupondje.be>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"David Christensen" <davidch@broadcom.com>
To: "Jean-Louis Dupond" <info@dupondje.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2624 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765664AbZFLWIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2009 18:08:40 -0400
In-Reply-To: <4A32CDE9.7020602@dupondje.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2009-06-12 at 14:51 -0700, Jean-Louis Dupond wrote:
> Hello!
> 
> Here is a mii-tool -vvv on a box that doesn't advertise gbit speeds! It 
> just doesn't advertise gbit @ random, sometimes it does, sometimes not! 
> Without any logic in it!
> 
> # mii-tool  -vvv
> Using SIOCGMIIPHY=0x8947
> eth0: link ok
>     registers for MII PHY 1:
>       1000 794d 0143 bed0 05e1 0000 0064 2001
>       0000 0300 0000 0000 0000 0000 0000 3000

Register 1 shows that autoneg did not complete (bit 5 is not set).
The tg3 device has advertised 10/100/1000 in register 4 and register 9,
but registers 5 and 0xa (link partner's advertisement registers are 0).

When it works, these registers should look very different.

Have you tried other cables?  What is the link partner?

>       0000 0101 0000 0000 0000 0000 0000 0000
>       7477 0104 0000 ffff 2801 0000 8000 0000
>     product info: vendor 00:50:ef, model 45 rev 0
>     basic mode:   autonegotiation enabled
>     basic status: link ok
>     capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
> 10baseT-FD 10baseT-HD
>     advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-
> control
> 
> # dmesg | grep tg3
> [    3.331702] tg3.c:v3.92.1 (June 9, 2008)
> [   18.238654] tg3: eth0: Link is up at 10 Mbps, half duplex.
> [   18.238654] tg3: eth0: Flow control is off for TX and off for RX.
> 
> 



