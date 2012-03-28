From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rose_dev: fix memcpy-bug in rose_set_mac_address
Date: Tue, 27 Mar 2012 22:49:34 -0400 (EDT)
Message-ID: <20120327.224934.2217174765482571048.davem@davemloft.net>
References: <4F71C05C.4040300@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932131Ab2C1CuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:50:00 -0400
In-Reply-To: <4F71C05C.4040300@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Tue, 27 Mar 2012 15:27:56 +0200

> This patch fixes a small bug in rose_set_mac_address. If the current and new
> MAC addresses match, then nothing needs to be done. However memcpy was used
> instead of memcmp for comparison.
> 
> The patch is against the latest net-tree.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

You're breaking this code, not fixing it.

If you don't keep the memcpy, then the calls right below which setup
the loopback node will use the previous device address not the new
one being configured.
