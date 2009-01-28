From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Tue, 27 Jan 2009 16:17:09 -0800
Message-ID: <20090127161709.25072f82@extreme>
References: <497EF9AC.70104@poczta.onet.pl>
	<adawscgwbkj.fsf@cisco.com>
	<20090127.160750.120120703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, aluno3@poczta.onet.pl,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36446 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606AbZA1ARL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 19:17:11 -0500
In-Reply-To: <20090127.160750.120120703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2009 16:07:50 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Roland Dreier <rdreier@cisco.com>
> Date: Tue, 27 Jan 2009 15:53:16 -0800
> 
> > but actually I still don't see how it's safe for a net driver to
> > call skb_linearize() from its transmit routine, since there's a
> > chance that that will unconditionally enable BHs?
> 
> It's simply not allowed.
> 
> dev_queue_xmit() at a higher level can do __skb_linearize()
> because it does so before doing the rcu_read_lock_bh().

If the device driver can't handle non-linear SKB's then it should
not set NETIF_F_SG.
