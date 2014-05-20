From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: modify tunnel's name when changing link's name
Date: Tue, 20 May 2014 12:21:56 -0700
Message-ID: <CAHA+R7O-yr5w6T2PUMXyofyZxmyyaGPSBUN67WTMVdvogmSmmA@mail.gmail.com>
References: <537AE7D1.4090702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	stephen hemminger <stephen@networkplumber.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:47164 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbaETTV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 15:21:57 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so786519lbi.13
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 12:21:56 -0700 (PDT)
In-Reply-To: <537AE7D1.4090702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 10:27 PM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>
> After executing command "ip tunnel add before local 192.168.0.19 mode gre",
> the tunnel "before" and the link "before" are created.
>
> Now if user executes command "ip link set dev before name after",
> the tunnel's name is still "before", but the link's name is
> "after". At last, user executes command "ip tunnel del before",
> and error "No such device" will arise.
>
> ip-tunnel uses ioctl to handle command. It firstly gets link through
> tunnel name, but because link has a different name with tunnel, so
> the error "No such device" arised.
>
> In order to handle this situation, tunnel's name should be modified
> when changing link's name.
>

NACK.

Renaming is just one of the events we miss for tunnels, you obviously
don't want add one netops for each of these events. Instead, we should have
a netdev notifier for every such tunnel devices.

I am working on a patch.
