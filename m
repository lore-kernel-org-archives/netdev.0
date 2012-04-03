From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 3/4] team: add binary option type
Date: Tue, 03 Apr 2012 18:38:16 -0400 (EDT)
Message-ID: <20120403.183816.230619298656469157.davem@davemloft.net>
References: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
	<1333227682-10235-4-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765Ab2DCWjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:39:24 -0400
In-Reply-To: <1333227682-10235-4-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 31 Mar 2012 23:01:21 +0200

> For transfering generic binary data (e.g. BPF code), introduce new
> binary option type.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Several issues:

> +		struct team_option_binary tbinary;

You put this into a netlink attribute, it has a non-fixed
type size because it uses pointer.  A compat task will do
the wrong thing and you won't interpret it's attribute
correctly.

> +			NLA_PUT_U8(skb, TEAM_ATTR_OPTION_TYPE, NLA_BINARY);

net-next no longer has NLA_PUT*(), so you'll need to adjust
this as well.
