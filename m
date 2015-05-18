From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/6] neigh: fix a possible leak issue of neigh
 entry
Date: Sun, 17 May 2015 21:58:02 -0700
Message-ID: <1431925082.621.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
	 <1431672946-300-3-git-send-email-ying.xue@windriver.com>
	 <1431691962.27831.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150515.113950.1408734283430265055.davem@davemloft.net>
	 <55595B64.70702@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	alexei@purestorage.com, joern@purestorage.com, ja@ssi.bg
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36545 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbERE6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 00:58:05 -0400
Received: by igbpi8 with SMTP id pi8so38693941igb.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 21:58:04 -0700 (PDT)
In-Reply-To: <55595B64.70702@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-18 at 11:24 +0800, Ying Xue wrote:

> If the issue of "neigh use-after-free" is fixed by the first patch although you
> said the atomic_read() was not safe for us, is the patch still wrong? If it's
> really wrong, can you please give more detailed explanation to help me
> understand why the change is wrong and but why a similar timer usage in
> sk_reset_timer() is not wrong?

Why do you believe sk_reset_timer() would be wrong ?

Difference between neigh_add_timer() and sk_reset_timer() is very
simple :

neigh_add_timer() must be called while the timer is not yet armed.

sk_reset_timer() can be called while timer is already armed.

You are changing neigh_add_timer() for no good reason, just because you
want it to be 'like sk_reset_timer()' ?
