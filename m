From: Christopher Li <sparse@chrisli.org>
Subject: Re: [net-next:master 98/98] drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34:
 sparse: cast to restricted __be16
Date: Mon, 3 Dec 2012 12:13:44 -0800
Message-ID: <CANeU7QkzUPksHvEL17sUbTezLGNHgMmUFvfyQcX39hEOuyufqQ@mail.gmail.com>
References: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com>
	<50B92A6D.8000600@myri.com>
	<20121130220228.GA22050@localhost>
	<50BCFBAA.5060001@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:65010 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab2LCUNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 15:13:45 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so2005422vby.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 12:13:44 -0800 (PST)
In-Reply-To: <50BCFBAA.5060001@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 3, 2012 at 11:21 AM, Andrew Gallatin <gallatin@myri.com> wrote:
> drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1434:35: warning:
> context imbalance in 'myri10ge_intr' - different lock contexts for basic
> block
>
> Which is apparently triggered by using __netif_tx_trylock().
> Is there something I'm missing, or does sparse just not like
> __netif_tx_trylock() because it divides spinlock acquisition and
> release into 2 different functions?
>

Right. Sparse currently does not have cross function analyse.
It will complain if the lock is not balanced with lock split into
different functions.

Chris
