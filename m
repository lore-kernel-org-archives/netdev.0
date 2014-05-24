From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dev-alloc-name-by-check-name-existence.patch
Date: Sat, 24 May 2014 17:57:27 -0400 (EDT)
Message-ID: <20140524.175727.1149146448761347899.davem@davemloft.net>
References: <1400968011-13023-1-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaEXV5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 17:57:38 -0400
In-Reply-To: <1400968011-13023-1-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cheng Renquan <crquan@gmail.com>
Date: Sat, 24 May 2014 14:46:51 -0700

> Nowadays the net_device names have been mounted on a hash table,
> check name existence should be much faster than ever before, hence
> the extra page of memory for bitmap scanning is no longer needed.
> 
> Signed-off-by: Cheng Renquan <crquan@gmail.com>

The cost is iterating creating the string over and over again
and then doing the hash lookup each time.

Whereas the bitmap lookup is one word sized load for every
BITS_PER_LONG indexes checked.

Did you even test your change with large numbers of devices?
