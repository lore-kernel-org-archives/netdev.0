From: David Miller <davem@davemloft.net>
Subject: Re: Connection with Smart Z hangs
Date: Mon, 03 Nov 2014 12:32:49 -0500 (EST)
Message-ID: <20141103.123249.877120069157206947.davem@davemloft.net>
References: <544D4DBB.9050103@libdivecomputer.org>
	<54566950.5080206@gmail.com>
	<CA+55aFzB+d8+pjvuPo-n5G7X9MK9vh9ER5zYLCXZBzjMD4bseA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlg.hessigheim@gmail.com, devel@libdivecomputer.org,
	netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbaKCRcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:32:52 -0500
In-Reply-To: <CA+55aFzB+d8+pjvuPo-n5G7X9MK9vh9ER5zYLCXZBzjMD4bseA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 2 Nov 2014 10:20:22 -0800

> David, I'm just going to remove that whole bogus disconnect call. It
> won't make things *work* for Martin (because this is all in the
> "connect failed" path), but that call as-is is just wrong, wrong,
> wrong. And apparently nobody cares about irda any more.

I totally agree, just kill it.  For the record this got added in:

commit 5b40964eadea40509d353318d2c82e8b7bf5e8a5
Author: Samuel Ortiz <samuel@sortiz.org>
Date:   Mon Oct 11 00:46:51 2010 +0200

    irda: Remove BKL instances from af_irda.c

which claims to be just a locking change, but obviously added
this bogus ->disconnect() call as well.

> If anybody is at all interested in helping maintain irda code, holler
> to David and to the netdev mailing list. The position is up for grabs.

Seriously... :-)
