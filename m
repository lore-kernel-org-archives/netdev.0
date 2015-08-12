From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6_mc_check_mld - kernel BUG at net/core/skbuff.c:1128
Date: Wed, 12 Aug 2015 07:26:11 -0700
Message-ID: <1439389571.29802.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMUH3-WBobHryNpxYUzuAr4bPBFkd=QFkWgOoLyGiVf6Qvx0Ww@mail.gmail.com>
	 <20150811205140.GD4402@odroid> <20150811214725.GE4402@odroid>
	 <20150811.215611.1190651644766573423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linus.luessing@c0d3.blue, bblanco@plumgrid.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35436 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbHLO0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 10:26:14 -0400
Received: by pacgr6 with SMTP id gr6so15684131pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 07:26:13 -0700 (PDT)
In-Reply-To: <20150811.215611.1190651644766573423.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-11 at 21:56 -0700, David Miller wrote:

> Calling pskb_expand_head() with a shared SKB is absolutely,
> positively, a bug.  You just don't understand why it is.

Definitely agree. Its a pain to find races otherwise.

skb_get() in general is quite tricky.

Better avoid it unless really needed in performance critical paths.

Relevant commits

ba34e6d9d346fe4e05d7e417b9edf5140772d34c tcp: make sure skb is not shared before using skb_get()

fc752f1f43c1c038a2c6ae58cc739ebb5953ccb0 ping: Fix race in free in receive path

1dc7b90f7cd050ef6d5e511e652347e52874469c ipv6: tcp: fix race in IPV6_2292PKTOPTIONS 
