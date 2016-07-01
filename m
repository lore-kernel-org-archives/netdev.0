From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: poll tx timeout only on active tx queues
Date: Fri, 01 Jul 2016 07:18:10 +0200
Message-ID: <1467350290.11238.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467295085-9204-1-git-send-email-saeedm@mellanox.com>
	 <1467296892.11238.24.camel@edumazet-glaptop3.roam.corp.google.com>
	,<CALzJLG-pjeZnOQ3FfZMLCz5KC-eXWWrTZS4yNi-+UYY=2T549A@mail.gmail.com>
	 <CO2PR11MB00889A8F46E66124C99E43DE97250@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36008 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbcGAFSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 01:18:13 -0400
Received: by mail-wm0-f46.google.com with SMTP id f126so11616282wma.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 22:18:13 -0700 (PDT)
In-Reply-To: <CO2PR11MB00889A8F46E66124C99E43DE97250@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-01 at 04:50 +0000, Yuval Mintz wrote:
> > currently all the device driver call  netif_tx_start_all_queues(dev)
> > on open to W/A this issue. which is strange since only
> > real_num_tx_queues are active.
> 
> You could also argue that netif_tx_start_all_queues() should
> only enable the real_num_tx_queues.
> [Although that would obviously cause all drivers to reach the
> 'problem' you're currently fixing].

Yep. Basically what I pointed out.

It seems inconsistent to have loops using num_tx_queues, and others
using real_num_tx_queues.

Instead of 'fixing' one of them, we should take a deeper look, even if
the change looks fine.

num_tx_queues should be used in code that runs once, like
netdev_lockdep_set_classes(), but other loops should probably use
real_num_tx_queues.

Anyway all these changes should definitely target net-next, not net
tree.
