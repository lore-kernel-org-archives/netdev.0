From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Sat, 31 Jan 2015 11:16:52 +0000
Message-ID: <20150131111652.GA22448@casper.infradead.org>
References: <20150131093637.GA29106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41618 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbbAaLQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 06:16:53 -0500
Content-Disposition: inline
In-Reply-To: <20150131093637.GA29106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/15 at 08:36pm, Herbert Xu wrote:
> The current being_destroyed check in rhashtable_expand is not
> enough since if we start a shrinking process after freeing all
> elements in the table that's also going to crash.

(The check in expand() is just an optimization to drop out of
 work cycles if it does not make sense to continue anymore.)

> 
> This patch adds a being_destroyed check to the deferred worker
> thread so that we bail out as soon as we take the lock.

Shouldn't the cancel_work_sync() in rhashtable_destroy() block
until the deferred worker is done and cancelled?
