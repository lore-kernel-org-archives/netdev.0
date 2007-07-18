From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 1/3] [net/core] move dev_mc_discard from dev_mcast.c to dev.c
Date: Wed, 18 Jul 2007 17:59:52 +0800
Message-ID: <91b13c310707180259v547ba2b3wc901102d35760a50@mail.gmail.com>
References: <11846606051099-git-send-email-crquan@gmail.com>
	 <11847264651509-git-send-email-crquan@gmail.com>
	 <20070718.021107.40833440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:38265 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbXGRJ7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:59:54 -0400
Received: by wr-out-0506.google.com with SMTP id 50so91628wra
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 02:59:54 -0700 (PDT)
In-Reply-To: <20070718.021107.40833440.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/18/07, David Miller <davem@davemloft.net> wrote:
> From: Denis Cheng <crquan@gmail.com>
> Date: Wed, 18 Jul 2007 10:41:03 +0800
>
> > Because this function is only called by unregister_netdevice,
> > this moving could make this non-global function static,
> > and also remove its declaration in netdevice.h;
> >
> > Any further, function __dev_addr_discard is also just called by
> > dev_mc_discard and dev_unicast_discard, keeping this two functions
> > both in one c file could make __dev_addr_discard also static
> > and remove its declaration in netdevice.h;
> >
> > Futhermore, the sequential call to dev_unicast_discard and then
> > dev_mc_discard in unregister_netdevice have a similar mechanism that:
> > (netif_tx_lock_bh / __dev_addr_discard / netif_tx_unlock_bh),
> > they should merged into one to eliminate duplicates in acquiring and
> > releasing the dev->_xmit_lock, this would be done in my following patch.
> >
> > Signed-off-by: Denis Cheng <crquan@gmail.com>
>
> Patch applied, thanks.
Thanks for applying, too.

And then the dev_mcast.c is now only 256 lines long(versus dev.c 4052 lines),
just left a few multicast related functions definition and "dev_mcast"
procfs code,
I have an idea to merge all code dev_mcast.c into dev.c, that would:

- remove two functions (__dev_addr_delete, __dev_set_rx_mode) from netdevice.h,
  and then tag them static,
  those two are also defined in dev.c and only called from dev_mcast.c,

- reducing one file would benefit the compilation process.

All in one word, I don't think the single file dev_mcast.c is needed anymore.

>


-- 
Denis Cheng
Linux Application Developer

"One of my most productive days was throwing away 1000 lines of code."
 - Ken Thompson.
