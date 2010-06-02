From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
 V5
Date: Wed, 2 Jun 2010 08:07:30 -0700
Message-ID: <20100602080730.53abea6d@nehalam>
References: <20100527180813.GA3714@psychotron.redhat.com>
	<20100527130822.02cb1661@nehalam>
	<20100528055154.GB2823@psychotron.redhat.com>
	<20100528061241.GC2823@psychotron.redhat.com>
	<1275030163.2650.3.camel@edumazet-laptop>
	<20100528073345.GD2823@psychotron.redhat.com>
	<20100601082805.1c84b16d@nehalam>
	<20100602075207.GD2603@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51259 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758393Ab0FBPHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 11:07:37 -0400
In-Reply-To: <20100602075207.GD2603@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jun 2010 09:52:08 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> +
> +	err = netdev_rx_handler_register(dev, macvlan_handle_frame);
> +	if (err) {
> +		rcu_assign_pointer(dev->macvlan_port, NULL);
> +		kfree(port);
> +	}
> +
> +	return err;
>  }

Rcu assign is not necessary here for because the hook didn't
get registered so there is no way for other CPU to see it.

-- 
