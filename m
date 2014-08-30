From: Florian Westphal <fw@strlen.de>
Subject: e1000: convert to build_skb/napi_gro_frags api
Date: Sat, 30 Aug 2014 20:28:20 +0200
Message-ID: <1409423307-23470-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43549 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751681AbaH3S2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 14:28:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000 driver preallocates skbs, then sends them up the stack.

This series changes the rx routine to only preallocate data buffers,
then initialize skb right before passing it up the stack.

This gives slight performance inprovements as the skb will be
fresh in the cache once its allocated/initialized.

The default-mtu 1500 path is converted to build_skb()/netdev_alloc_frag.

Jumbo path is converted to napi_gro_frags.

Note that this has only been tested with kvms e1000 emulation.
