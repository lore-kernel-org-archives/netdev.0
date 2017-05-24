From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] bpf: fix incorrect pruning decision when
 alignment must be tracked
Date: Wed, 24 May 2017 16:07:33 -0400 (EDT)
Message-ID: <20170524.160733.216900339299848648.davem@davemloft.net>
References: <cover.1495556127.git.daniel@iogearbox.net>
        <cover.1495556127.git.daniel@iogearbox.net>
        <170aa8062f2c54186a6567b5be8fca0cddec53be.1495556127.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49858 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754593AbdEXUHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 16:07:35 -0400
In-Reply-To: <170aa8062f2c54186a6567b5be8fca0cddec53be.1495556127.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 23 May 2017 18:30:41 +0200

> +	if (!env->strict_alignment && old->off <= cur->off &&

You can't just test env->strict_alignment by itself, that's just an
override and doesn't determine the actual "strict" value we use which
is a combination of env->strict_alignment and
"!CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS".

So you'll have to update this test.
