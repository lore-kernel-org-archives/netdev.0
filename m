From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Sat, 23 Aug 2008 20:35:07 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0808232034380.8996@fbirervta.pbzchgretzou.qr>
References: <20080821220432.GT31136@x200.localdomain> <alpine.LNX.1.10.0808211903000.20596@fbirervta.pbzchgretzou.qr> <20080822113028.GB2321@x200.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33501 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbYHXAfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 20:35:10 -0400
In-Reply-To: <20080822113028.GB2321@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2008-08-22 07:30, adobriyan@gmail.com wrote:
>
>We wait for untracked ct refcount to drop to 1 back:
>
>	/* wait until all references to nf_conntrack_untracked are dropped */
>	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
>		schedule();
>
>Consequently it should be one per netns, otherwise netns A can prevent
>netns B from stopping.
>

But nf_conntrack_cleanup is not per netns, is it?
At least I do not think it should be.
