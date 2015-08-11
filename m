From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: ipv6_mc_check_mld - kernel BUG at net/core/skbuff.c:1128
Date: Tue, 11 Aug 2015 22:51:40 +0200
Message-ID: <20150811205140.GD4402@odroid>
References: <CAMUH3-WBobHryNpxYUzuAr4bPBFkd=QFkWgOoLyGiVf6Qvx0Ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:47128 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbbHKU5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 16:57:51 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id 0C22F586A4E
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 22:51:41 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CAMUH3-WBobHryNpxYUzuAr4bPBFkd=QFkWgOoLyGiVf6Qvx0Ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2015 at 02:56:12PM -0700, Brenden Blanco wrote:
> Doing some code reading with Alexei, we found a suspect commit, which
> introduces an skb_get and skb_may_pull of the same skb, which leads to the BUG
> when skb->len == len.

Urgh, didn't know that pskb_may_pull() doesn't like an skb with a
reference count greater than one... But yes, the BUG() call in
skbuff.c:1128 / pskb_expand_head() says that (though in this case
the BUG() in skbuff.c call actually seems kinda weird (/"wrong"?), as
it isn't shared between different code paths).

Thanks for the thorough analysis, going to provide a patch within
the next 24h (hopefully).

Cheers, Linus
