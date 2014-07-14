From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Mon, 14 Jul 2014 23:38:44 +0300
Message-ID: <CAJZOPZLwiT7LhxDFYdAq=0iU6heSwBQfCvwxXtoAXMqg=eNAmA@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
	<CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
	<CAPshTCjiw8vFK9Y4APwsX5kWnKDByLuOn+1MJa4C08FOevZKQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>, Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:58563 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757034AbaGNUip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 16:38:45 -0400
Received: by mail-qg0-f44.google.com with SMTP id j107so3944052qga.17
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 13:38:44 -0700 (PDT)
In-Reply-To: <CAPshTCjiw8vFK9Y4APwsX5kWnKDByLuOn+1MJa4C08FOevZKQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 10:16 PM, Jerry Chu <hkchu@google.com> wrote:
> On Mon, Jul 14, 2014 at 12:05 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> On Sun, Jul 13, 2014 at 5:46 PM, H.K. Jerry Chu <hkchu@google.com> wrote:
>>> Fixed a bug that was introduced by my GRE-GRO patch
>>> (bf5a755f5e9186406bbf50f4087100af5bd68e40 net-gre-gro: Add GRE
>>> support to the GRO stack) that breaks the forwarding path
>>> because various GSO related fields were not set. The bug will
>>> cause on the egress path either the GSO code to fail, or a
>>> GRE-TSO capable (NETIF_F_GSO_GRE) NICs to choke. The following
>>> fix has been tested for both cases.

>> Anything different in this version vs. the one you posted earlier on
>> February or this is a plain re-post?

> I simply moved the patch against the latest net-next and resolved some small
> conflict so yes it's pretty much the same.

OK, got it.

> Also I don't see the subsequent
> discussion on skb->encapsulation affects the validity of this patch so
> i'm resubmitting it. Also the patch has been confirmed to address the problem
> Wolfgang reported last week. Feel free to test against the configuration (VXLAN?)
> you had some question about earlier.

Well, re-reading that thread, we were not very decisive there... my
comment of setting the inner network header twice in inet_gro_complete
doesn't apply only to vxlan but to other tunneling protocols. Also, if
we really need (why do we? or explained it on the Feb thread) to set
skb->encapsulation for the sake of TX in a protocol (GRE) gro
complete, looks a bit fishy to me... but saying this I think brings us
back to that incomplete discussion [1]  sounds as this needs some
plumbering... Still, this way or another I understand a regression was
introduced here and should be fixed.

Or.

[1] http://marc.info/?t=139353642700003&r=1&w=2
