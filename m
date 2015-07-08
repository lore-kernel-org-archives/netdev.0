From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v2 4/5] ipvlan: protect addresses with internal spinlock
Date: Tue, 7 Jul 2015 21:05:00 -0700
Message-ID: <CAF2d9jipwzVPNcaiQduPkDyoy3OXQG4UW=VB4HyVPjyrU2bU1w@mail.gmail.com>
References: <20150703125132.24121.50592.stgit@buzz> <20150703125840.24121.91556.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:35071 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbbGHEFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 00:05:20 -0400
Received: by ykfs198 with SMTP id s198so92258602ykf.2
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 21:05:19 -0700 (PDT)
In-Reply-To: <20150703125840.24121.91556.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 3, 2015 at 5:58 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> Inet6addr notifier is atomic and runs in bh context without RTNL when
> ipv6 receives router advertisement packet and performs autoconfiguration.
>
> This patch adds ipvl_port->addr_lock and helpers: ipvlan_addr_lock_bh,
> ipvlan_addr_unlock_bh for protecting ipvlan addresses and hash table.
>
Frankly I'm not comfortable adding spin-locks all over. I think any
config that mostly takes place with RTNL makes sense but this
inet6addr needs to be thought through and implanting spin-locks in
IPvlan is a work-around for a problem some where else.
Why can't a work-queue that takes RTNL to call inet6addr-notifier be
implemented when called from bh?

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  drivers/net/ipvlan/ipvlan.h      |   11 +++++++++++
>  drivers/net/ipvlan/ipvlan_core.c |    2 --
>  drivers/net/ipvlan/ipvlan_main.c |   33 ++++++++++++++++++++++++++++++---
>  3 files changed, 41 insertions(+), 5 deletions(-)
>
[snip]
