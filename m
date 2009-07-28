From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] pppoe: fix race at init time
Date: Tue, 28 Jul 2009 22:48:34 +0400
Message-ID: <20090728184834.GD4678@lenovo>
References: <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org> <4A6EFA35.3060309@gmail.com> <4A6EFB81.4090105@gmail.com> <4A6F017B.4060909@gmail.com> <4A6F397D.6010606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:46321 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbZG1Ssp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 14:48:45 -0400
Received: by fxm12 with SMTP id 12so232078fxm.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 11:48:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A6F397D.6010606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Eric Dumazet - Tue, Jul 28, 2009 at 07:46:37PM +0200]
... 
| So Igor still has a panic... lets try a third patch then :)
| 
| [PATCH] pppoe: fix race at init time
| 
| I believe we have a race in ppoe_init() :
| 
| As soon as dev_add_pack(&pppoes_ptype); and/or dev_add_pack(&pppoed_ptype); 
| are called, we can receive packets while nets not yet fully ready
| (ie : pppoe_init_net() not yet called)
| 
| This means we should be prepared to get a NULL pointer
| from net_generic(net, pppoe_net_id) call.
| 
| We miss this NULL check in get_item() and possibly crash if this nets 
| has no struct pppoe_net attached yet. Other subroutines
| are safe.

Hmm. It seems the problem is not in pppoe_init_net since it's
called *before* dev_add_pack via register_pernet_gen_device
(which is protected by a global net mutex). Or I miss something?

(sorry guys I have quite a limited internet connection this week)

	-- Cyrill
