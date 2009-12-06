From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Sun, 6 Dec 2009 19:53:09 +0100
Message-ID: <20091206185309.GB3870@ami.dom.local>
References: <4B1A4E07.4030804@gmail.com>
 <4B1AD0CD.4040407@gmail.com>
 <4B1B6F87.6050201@gmail.com>
 <20091206182210.GA3870@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:41391 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757113AbZLFSxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 13:53:25 -0500
Received: by bwz27 with SMTP id 27so3032374bwz.21
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2009 10:53:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091206182210.GA3870@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 06, 2009 at 07:22:10PM +0100, Jarek Poplawski wrote:
> AFAICS this lock here can only to prevent double linking to the
> unused_peers list during such transitions. If so, it could be replaced
> with the list_empty(&p->unused) test before list_add_tail(), and
> atomic_dec_test() without the lock would be enough (unless I miss
> something ;-).

Hmm... But I missed something: the last atomic_dec() should be done
under the lock yet, so let's forget it.

Jarek P.
