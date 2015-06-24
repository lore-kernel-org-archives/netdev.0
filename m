From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sock_hold and sock_put
Date: Wed, 24 Jun 2015 14:46:40 +0200
Message-ID: <1435150000.4110.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGZFCEHHXbnsSoBaTUdxqwoQ75hN5BTBXJMEXp0dkwQbFSEkRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-newbie <linux-newbie@vger.kernel.org>
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34116 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbbFXMqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 08:46:44 -0400
In-Reply-To: <CAGZFCEHHXbnsSoBaTUdxqwoQ75hN5BTBXJMEXp0dkwQbFSEkRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-24 at 14:47 +0530, ratheesh kannoth wrote:
> Hi list,
> 
> There is a comment on sock_hold() function -
> 
> 561 /* Grab socket reference count. This operation is valid only
> 562    when sk is ALREADY grabbed f.e. it is found in hash table
> 563    or a list and the lookup is made under lock preventing hash table
> 564    modifications.
> 565  */
> 
> 
> But i could see instances of sock hold() in kernel  without any locks.
> 
> 
> How  the race between sock_hold() and sock_put() is prevented in  smp ?
> 
> note: I would like to use sock_hold() and sock_put() in
> netdev_notifier chain call back functions.

You misunderstood the comment.

Comment only stated that sock_hold() must be used in contexts where
caller owns a reference (and will eventually release it later with
sock_put().

There is nothing about having a lock here.
