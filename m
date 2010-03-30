From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH -next] x86, fs: add sys_compat_write for net/socket.c
Date: Tue, 30 Mar 2010 20:48:58 +0200
Message-ID: <201003302048.59350.arnd@arndb.de>
References: <1269971469-1254-1-git-send-email-fw@strlen.de> <4BB23B35.7060401@zytor.com> <20100330181757.GB14721@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, x86@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:60499 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab0C3StX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 14:49:23 -0400
In-Reply-To: <20100330181757.GB14721@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 March 2010 20:17:57 Florian Westphal wrote:
> Now, I realize that adding a write compat syscall is borderline
> insanity, and I am open to suggestions.

Another option, which may be marginally better, would be to redefine
the data structures to be compatible, and assign them new numbers,
with kernel compat support for the numbers in x86-32 binaries.

If you manually add padding to the new data structures in the places
that the other architectures have implicit padding, the hack will only
be needed on x86-32 and compat x86-64.

The obvious disadvantage is that you need to recompile the x86-32
binaries to work in compat mode.

	Arnd
