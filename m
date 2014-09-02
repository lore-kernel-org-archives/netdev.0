From: Florian Westphal <fw@strlen.de>
Subject: [PATCH V2 0/7] e1000: convert to build_skb/napi_gro_frags api
Date: Tue,  2 Sep 2014 14:24:43 +0200
Message-ID: <1409660690-10391-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48626 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753406AbaIBMY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 08:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v1:
 - in last patch, remove unneeded parens and casts,
 pointed out by Sergei Shtylyov.

v1 cover letter:

e1000 driver preallocates skbs, then sends them up the stack.

This patch series changes the rx routine to only preallocate
packet buffers, then allocate the skb right before sending the
packet up the stack.

This gives slight performance inprovements as the skb will be
fresh in the cache once its allocated/initialized.

The default-mtu 1500 path is converted to
build_skb()/netdev_alloc_frag.

Jumbo path is converted to napi_gro_frags.

Note that this has only been tested with
kvms e1000 emulation.
