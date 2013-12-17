From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net-next] net: vxlan: use custom ndo_change_mtu
 handler
Date: Tue, 17 Dec 2013 15:40:52 -0800
Message-ID: <20131217154052.6e641cf2@nehalam.linuxnetplumber.net>
References: <1387322468-17368-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:41918 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab3LQXkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 18:40:55 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so7593521pbb.16
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 15:40:55 -0800 (PST)
In-Reply-To: <1387322468-17368-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 00:21:08 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> When adding a new vxlan device to an "underlying carrier" (here:
> dst->remote_ifindex), the MTU size assigned to the vxlan device
> is the MTU at setup time of the carrier - needed headroom, when
> adding a vxlan device w/o explicit carrier, then it defaults
> to 1500.
> 
> In case of an explicit carrier that supports jumbo frames, we
> currently cannot change vxlan MTU via ip(8) to > 1500 in
> post-setup time, as vxlan driver uses eth_change_mtu() as default
> method for manually setting MTU.
> 
> Hence, use a custom implementation that only falls back to
> eth_change_mtu() in case we didn't use a dev parameter on device
> setup time, and otherwise allow a max MTU setting of the carrier
> incl. adjustment for headroom.
> 
> Reported-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

This code is good thanks.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>

P.s: I wonder if notifier handler would be good to handle changes
to underlying device MTU on the fly.
