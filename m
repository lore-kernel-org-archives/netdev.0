From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 GIT state
Date: Thu, 09 Aug 2007 02:28:23 -0700 (PDT)
Message-ID: <20070809.022823.31781972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758154AbXHIJ2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 05:28:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 727C3510001
	for <netdev@vger.kernel.org>; Thu,  9 Aug 2007 02:28:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, as is clear for some the net-2.6.24 tree has been cut
and is at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.24.git

Contents:

1) napi_struct V6 :-)
2) LRO with EHEA and Myri10g ports
3) mac80211 merge with John Linville
4) Some netlink bits from Thomas Graf
5) VETH driver

For shits and grins I build a powerpc cross environment and used
this to fix up the EHEA build fallout.  That means nobody with
these chips did any testing at all, please do so if you can.

SIS190 didn't build because it had a half-done NAPI implementation
(actually closer to not done) and it did netif_poll_{enable,disable}()
(and wrongly) in it's open and close routines.  Doing this
unconditionally, even when non-NAPI, is just wrong and therefore since
the NAPI related bits were miniscule I just ripped out all of it to
fix that.

Natsemi and pasemi_mac were missing a few netif_poll_{disable,enable}()
conversions to napi_{enable,disable}().

I found one driver whose conversion got missed, ibm_emac, but I can't
enable that in the powerpc64 build because it's guarded against when
PPC_MERGE is enabled which ppc64 sets unconditionally.

I might take a stab at converting that guy (it's similar to
EHEA and can use multi-queue NAPI quite directly although
the access back up to the parent netdev is a bit tricky)
but if someone can beat me to it... Hint hint!

I'm now doing a powerpc allmodconfig build to try and shake out
any other build regressions added by the net-2.6.24 tree changes.

I'll be going over the TCP bits Ilpo and I have been discussing
then expect me to disappear back to driver hacking :-)  As is,
there should be enough in there for people to play with,
regression test, and improve.

Thanks.
