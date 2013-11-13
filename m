From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel >
 3.10
Date: Wed, 13 Nov 2013 15:12:44 +0100
Message-ID: <20131113141244.GM19702@redhat.com>
References: <52838590.5070806@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755556Ab3KMOPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 09:15:03 -0500
Content-Disposition: inline
In-Reply-To: <52838590.5070806@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 02:58:40PM +0100, Stefan Priebe - Profihost AG wrote:
>Hello,
>
>while my vlans, bridging and bonding stuff was working until 3.9 i never
>thought about how it is right. So maybe i was always wrong.
>
>I've this:
>
>eth2
>     \
>      -- bond1 -- vmbr1
>     /
>eth3
>
>This works fine and as expected now i want to have a vlan using the
>bonding and using a bridge.
>
>I the past i had this:
>eth2
>     \
>      -- bond1 -- vmbr1
>     /              \
>eth3                 \ vmbr1.3000
>                           \ ---- tap114i1
>
>This was working fine until 3.9.X since 3.10. Right now using 3.10 i
>need to put eth2 and eth3 into promisc mode to get it working ;-( this
>is bad!

As a guess - do you use arp monitoring for bonding? Try using miimon -
there were some issues with it in 3.10, which were fixed by some huge
patchsets that will never hit 3.10 stable.

Also, the bonding configuration would be welcome.

>
>I also tried this one without success:
>eth2
>     \
>      -- bond1 -- vmbr1
>     /     \
>eth3        ----- bond1.3000 --- vmbr1v3000
>                                     \ ---- tap114i1
>
>
>
>Greets,
>Stefan
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
