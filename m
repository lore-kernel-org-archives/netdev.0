From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 22:00:10 -0700 (PDT)
Message-ID: <20120821.220010.1158630981089834558.davem@davemloft.net>
References: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	<5034591E.3040908@zytor.com>
	<CA+55aFz39tCSO7sf7+czNEBcEx7q4=KbnAcKEoS-KBwr6D3Psg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, bhutchings@solarflare.com, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046Ab2HVFAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 01:00:13 -0400
In-Reply-To: <CA+55aFz39tCSO7sf7+czNEBcEx7q4=KbnAcKEoS-KBwr6D3Psg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 21 Aug 2012 21:35:22 -0700

> My biggest reason to question this all is that I don't think it's
> worth it. Why would we ever care to do all this in the first place?
> There's no really sane use for it.

All the x86 crypto code hits this case all the time, easiest example
is doing a dm-crypt on a block device when an IPSEC packet arrives.

The crypto code has all of this special code and layering that is
there purely so it can fall back to the slow non-optimized version
of the crypto operation when it hits this can't-nest-fpu-saving
situation.
