From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [PATCH 1/3] net: bgmac: allocate struct bgmac just once & don't
 copy it
Date: Fri, 27 Jan 2017 17:02:33 +0100
Message-ID: <8bb6614b-a4af-d435-7db8-616cb1c1a56d@nbd.name>
References: <20170127092043.17413-1-zajec5@gmail.com>
 <20170127092043.17413-2-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:46454 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932198AbdA0QCh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 11:02:37 -0500
In-Reply-To: <20170127092043.17413-2-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-01-27 10:20, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> To share as much code as possible in bgmac we call alloc_etherdev from
> bgmac.c which is used by both: platform and bcma code. The easiest
> solution was to use it for allocating whole struct bgmac but it doesn't
> work well as we already get early-filled struct bgmac as an argument.
> 
> So far we were solving this by copying received struct into newly
> allocated one. The problem is it means storing 2 allocated structs,
> using only 1 of them and non-shared code not having access to it.
> 
> This patch solves it by using alloc_etherdev to allocate *pointer* for
> the already allocated struct. The only downside of this is we have to be
> careful when using netdev_priv.
> 
> Another solution was to call alloc_etherdev in platform/bcma specific
> code but Jon advised against it due to sharing less code that way.
How does that lead to sharing less code?
I find this pointer indirection rather ugly and uncommon, and I think it
would be much cleaner to split the probe into bgmac_enet_alloc and
bgmac_enet_probe (with bgmac_enet_alloc calling alloc_etherdev and doing
basic setup).

- Felix
