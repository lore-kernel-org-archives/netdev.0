From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce netdevice gso_min_segs attribute
Date: Sun, 05 Oct 2014 11:58:37 -0700
Message-ID: <1412535517.11091.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
	 <54312F50.2060608@mellanox.com>
	 <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx9qLU_6OgLQ=GW+V2UwZ2h_GqrzAHhYL_0BP8p8AzVd=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:43505 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbaJES6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 14:58:40 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so2165772pdj.12
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 11:58:39 -0700 (PDT)
In-Reply-To: <CA+mtBx9qLU_6OgLQ=GW+V2UwZ2h_GqrzAHhYL_0BP8p8AzVd=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-10-05 at 11:45 -0700, Tom Herbert wrote:
> On Sun, Oct 5, 2014 at 10:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Some TSO engines might have a too heavy setup cost, that impacts
> > performance on hosts sending small bursts (2 MSS per packet).
> >
> > This patch adds a device gso_min_segs, allowing drivers to set
> > a minimum segment size for TSO packets, according to the NIC
> > performance.
> >
> Eric, this seems like another device specific limitation in TSO we are
> exposing to the stack. Can't we just put things like this in
> ndo_gso_check so driver can apply whatever criteria it wants in
> deciding if it worth it or even to rather do TSO?

I don't think it really matters where the check is done.

If you want to move the check away from netif_skb_features(), its fine
with me, but please note you did not suggest this for current check
against gso_max_segs.

I based my patch on current net-next, where ndo_gso_check() does not
exist.

BTW, I wonder now why we added gso_max_segs support to bonding driver.
(commit 0e376bd0b791ac6ac6bdb051492df0769c840848)

It makes little sense, gso should be done at the last possible stage.
