From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 10/31] cxgb4/iw_cxgb4: Doorbell Drop Avoidance
 Bug Fixes.
Date: Thu, 27 Feb 2014 10:21:25 -0800
Message-ID: <20140227102125.5e95620d@nehalam.linuxnetplumber.net>
References: <1393427230-14532-11-git-send-email-hariprasad@chelsio.com>
	<20140226.181216.1563503549713890339.davem@davemloft.net>
	<005101cf33df$00749e40$015ddac0$@opengridcomputing.com>
	<20140227.130544.1892840202381139797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, hariprasad@chelsio.com,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	roland@purestorage.com, kumaras@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, santosh@chelsio.com, nirranjan@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:52443 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbaB0SV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 13:21:29 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so2756543pdj.31
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:21:29 -0800 (PST)
In-Reply-To: <20140227.130544.1892840202381139797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Feb 2014 13:05:44 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: "Steve Wise" <swise@opengridcomputing.com>
> Date: Thu, 27 Feb 2014 11:11:49 -0600
> 
> >> 
> >> > -static int allow_db_fc_on_t5;
> >> > -module_param(allow_db_fc_on_t5, int, 0644);
> >> > -MODULE_PARM_DESC(allow_db_fc_on_t5,
> >> > -		 "Allow DB Flow Control on T5 (default = 0)");
> >> > -
> >> > -static int allow_db_coalescing_on_t5;
> >> > -module_param(allow_db_coalescing_on_t5, int, 0644);
> >> > -MODULE_PARM_DESC(allow_db_coalescing_on_t5,
> >> > -		 "Allow DB Coalescing on T5 (default = 0)");
> >> 
> >> Module parameters are a user facing interface.
> >> 
> >> You cannot just delete, or change the semantics of, the ones you feel
> >> like doing so to.
> > 
> > I see your point on user facing interfaces.   These module params were
> > added initially to allow tweaking the db drop recovery for T5 devices in
> > the thought that we might need it.  It turns out T5 doesn't suffer from
> > this issue.  These params default to 0 anyway, and I doubt anyone has
> > changed them.  Disabling the hw db coalescing feature proved problematic
> > and it turned out to even make the issue worse, so I removed it totally
> > at the recommendation from the HW engineers, and put in place the new
> > design which better rate controls things under heavy load.
> 
> You have to keep the old ones around.

You can keep the parameters but ignore them however.
