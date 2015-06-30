From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Caller or callee setting skb->network_header?
Date: Tue, 30 Jun 2015 04:01:02 +0200
Message-ID: <20150630020101.GD2897@odroid>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:40599 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbbF3CBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 22:01:07 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id B7390586848
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 04:01:03 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

For an .ndo_start_xmit handler, can the callee rely on the caller
setting the skb network header?

Or should the callee set it before performing any
skb_network_header()/ip_hdr()/ipv6_hdr()/... calls?

Cheers, Linus

PS: Currently looking at batman-adv's ndo_start_xmit handler
"interface_tx()", whether an skb_set_network_header() should be
added there as it uses ip_hdr()/ipv6_hdr() later
(-> batadv_mcast_forw_mode_check_ipv{4,6}()). Testing this in
VMs it seemed to be set correctly by the caller, but wanted to
check whether this can or shouldn't be relied on.
