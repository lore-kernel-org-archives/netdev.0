From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gen_estimator: change the lock order for
 better perfermance
Date: Tue, 17 Sep 2013 04:11:48 -0700
Message-ID: <1379416308.29845.11.camel@edumazet-glaptop>
References: <1379407101-18933-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:44013 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305Ab3IQLLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 07:11:50 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so5369744pbc.30
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 04:11:49 -0700 (PDT)
In-Reply-To: <1379407101-18933-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-17 at 16:38 +0800, Hong Zhiguo wrote:
> From: Hong Zhiguo <zhiguohong@tencent.com>
> 
> e->stats_lock is usually taken by fast path to update stats.
> In the old order, fast path should wait for write_lock(&est_lock).
> Even though it's only one line inside the write_lock(&est_lock),
> but if there's interrupt or page fault, a lot of spin on
> e->stats_lock will be wasted in fast path.

1) net-next is not open

2) There is no way a page fault can happen in this path.

3) This patch is wrong.

Current order is there for good reasons.

Have you really tried LOCKDEP, before sending a patch changing lock
order ?
