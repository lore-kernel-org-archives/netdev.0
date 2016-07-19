From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v0 00/10] Convert Netgear WNR854T to devicetree
Date: Tue, 19 Jul 2016 11:04:44 -0400
Message-ID: <87wpkhy8hf.fsf@ketchup.mtl.sfl>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk> <20160716205304.GA5075@lunn.ch> <alpine.DEB.2.11.1607171043100.19980@marmot.wormnet.eu> <20160717153338.GA13611@lunn.ch> <alpine.DEB.2.11.1607190933590.19980@marmot.wormnet.eu> <20160719141640.GZ31103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, Jamie Lentin <jm@lentin.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54748 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbcGSPEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 11:04:50 -0400
In-Reply-To: <20160719141640.GZ31103@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> [Reducing the Cc: list a bit to networking people]
>
>> Okay. Frames sent from the port are EDSA-tagged (which isn't exactly
>> surprising), but I'm yet to see the switch receive 0xdada frames.
>> Even with the net-next branch which uses DSA_TAG_PROTO_EDSA for all
>> chip types.
>> 
>> However, the ethertype is reflecting the port:-
>> 
>> lan1/5 : ethertype Unknown (0xc028), length 176:
>> lan2/7 : ethertype Unknown (0xc038), length 176:
>> lan3/0 : ethertype Unknown (0xc000), length 176:
>> lan4/1 : ethertype Unknown (0xc008), length 176:
>> wan/2  : ethertype Unknown (0xc010), length 176:
>
> O.K, we broke it :-(
>
> The 6185 does not support EDSA, only DSA.

I'm wondering if EDSA could be simulated on 6185 (only) with the
CoreTagType register (0x19) and DoubleTag bit in Port Control (0x04)...

> Or we do something more radical, like add a driver callback to return
> the tagging protocol, rather than hard code it in the structure? We
> can then use a capability flag.

The driver callback is the way to go. The supported tag format is
identifiable via the register layout. 6352 and newer have a 2-bit
FrameMode in Port Control (0x04), while 6185 has a single DSA_Tag bit.

A new switch operation can return the tag protocol enum, or an exposed
xmit/recv pair from net/dsa/tag_*.c, which must be used by the CPU.

Note: 88E6060 (which is likely to be supported by mv88e6xxx) has the
same issue and requires this, since it uses the Trailer tagging format.

Thanks,

        Vivien
