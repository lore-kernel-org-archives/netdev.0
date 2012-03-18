From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Sun, 18 Mar 2012 09:00:47 +0200
Message-ID: <20120318090047.0b14ac98@vostro>
References: <20120314215142.655ae607@vostro>
	<1331755965.6022.55.camel@edumazet-glaptop>
	<20120314223343.23dc9df3@vostro>
	<20120314205319.GA28394@electric-eye.fr.zoreil.com>
	<20120315080635.1f76512b@vostro>
	<20120315171148.0050714d@vostro>
	<20120315191118.GA19809@electric-eye.fr.zoreil.com>
	<20120316221557.235f5ffd@vostro>
	<20120317115625.3fc04de4@vostro>
	<20120317113501.GC20532@electric-eye.fr.zoreil.com>
	<20120317222004.GA25455@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:60396 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab2CRHBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 03:01:32 -0400
Received: by wibhq7 with SMTP id hq7so2552727wib.1
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 00:01:31 -0700 (PDT)
In-Reply-To: <20120317222004.GA25455@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Mar 2012 23:20:04 +0100 Francois Romieu
<romieu@fr.zoreil.com> wrote:

> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> > > Or as easy alternative, enabling the VPD bit in Config1 should
> > > allow me to read the EEPROM contents using the PCI /sys/.../vpd
> > > interface, right?
> > 
> > In theory, yes. I have not tested it. Imho both access methods will
> > be useful.
> 
> I tried vpd and got the eeprom content, duplicated 256 times.
> 
> The eeprom content is fairly boring:
> 
> # ethtool -e
> 8169sc-1 Offset          Values
> ------          ------
> 0x0000          29 81 ec 10 67 81 ec 10 67 81 20 40 01 a1 00 e0 
> 0x0010          4c 67 00 01 15 cd c2 f7 ff 80 ff ff ff ff ff 13 
> 0x0020          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0030          ff ff fa d6 ff ff ff ff ff ff ff ff ff ff ff 20 
> 0x0040          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0050          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0060          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 

Ok. Thanks. I should be able to swap my broken box tomorrow or the day
after, and then start doing expirements and compare the eeprom.

I also found one more weirdly broken box. One of my similar boxes fails
to LACP bonding with a HP ProCurve switches. The switch just says LACP
failed, but linux thinks it's ok and starts aggregation, and this
results in broken traffic for all flows using the link that was not
accepted as part of the aggregation by the switch.

To only explanation I've found so far is: the switch reports other link
as MDI and the other as MDI-X. And this is enough to fail the
aggregation (links are not identical), but the linux bonding does not
notice this. I have no idea why the other link is MDI-X - it's a
straight cable. I wonder if it could be eeprom related too... or maybe
it's just another broken NIC.

Oh well - I'll get back to this after few days when I have the broken
box on my table for playing.
