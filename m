From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: fix a double free issue for neighbour entry
Date: Wed, 20 May 2015 03:45:37 -0700
Message-ID: <1432118737.4060.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432085113-25063-1-git-send-email-ying.xue@windriver.com>
	 <1432099637.4060.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555C313E.1020003@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	alexei@purestorage.com, joern@purestorage.com, ja@ssi.bg
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34746 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbbETKpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:45:40 -0400
Received: by igbhj9 with SMTP id hj9so57573812igb.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 03:45:39 -0700 (PDT)
In-Reply-To: <555C313E.1020003@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 15:01 +0800, Ying Xue wrote:

> Time 4:
> CPU 0:
> Release the neigh whose refcnt was increased from 0 to zero.
> neigh_release() is called by someone. As the neigh is already freed, panic
> happens!!!

There is a bug for sure, although I never saw it ever happening.

I am only saying your 'fix' is not appropriate.

You focus on refcnt which is the wrong thing to test in this context.

Even if we decided to remove RCU locking and go back to rwlock, refcnt
would not be the thing to test.
