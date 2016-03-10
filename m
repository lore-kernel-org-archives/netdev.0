From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] bpf: make bpf_stackmap_copy conditionally called
Date: Thu, 10 Mar 2016 10:11:10 +0100
Message-ID: <201603101011.11010.arnd@arndb.de>
References: <1457574245-2998842-1-git-send-email-arnd@arndb.de> <20160310033845.GA62491@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:62064 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935229AbcCJJLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 04:11:53 -0500
In-Reply-To: <20160310033845.GA62491@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 10 March 2016, Alexei Starovoitov wrote:
> yes. this is also ok-ish fix.
> I've sent different version already:
> http://patchwork.ozlabs.org/patch/595617/
> 
> I considered the option like yours but it's relying on gcc doing
> dead code elimination of 'if (false) {}' branch and though kernel
> is never compiled with -O0. I didn't want to take the risk.
> I'm fine with either approach though.

Ok, and I see yours is already applied, so that's fine.

In general, I don't like __weak symbols in the kernel as they
make it less clear what is actually getting called, and I think my
version would have been safe, we rely on building with -O2 or -Os
in a lot of places because of similar things.

	Arnd
