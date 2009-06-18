From: Jiri Slaby <jirislaby@gmail.com>
Subject: inet_csk_get_port lock imbalance?
Date: Thu, 18 Jun 2009 15:55:54 +0200
Message-ID: <4A3A476A.1060808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f212.google.com ([209.85.220.212]:46369 "EHLO
	mail-fx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbZFRNzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 09:55:51 -0400
Received: by fxm8 with SMTP id 8so1064197fxm.37
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 06:55:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we've found a weird locking discipline in inet_csk_get_port. Who is
supposed to unlock the spin lock in the place marked in the code below?

do {
        head = &hashinfo->bhash[inet_bhashfn(net, rover,
                        hashinfo->bhash_size)];
        spin_lock(&head->lock);
        inet_bind_bucket_for_each(tb, node, &head->chain)
                if (ib_net(tb) == net && tb->port == rover) {
...
		}
        break;  ////////// here
next:
        spin_unlock(&head->lock);
        if (++rover > high)
                rover = low;
} while (--remaining > 0);

Thanks.

