From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Wed, 19 Nov 2008 02:08:10 +1030
Message-ID: <200811190208.11346.rusty@rustcorp.com.au>
References: <200811172050.31308.rusty@rustcorp.com.au> <4921F1DE.9080305@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56132 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752026AbYKRPiW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 10:38:22 -0500
In-Reply-To: <4921F1DE.9080305@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 18 November 2008 09:06:14 Eric Dumazet wrote:
> Rusty Russell a =C3=A9crit :
> > There's no reason for this to be dynamically allocated: we panic if
> > allocation fails anyway.
> >
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> Well, since we dont have "per_cpu bss", this also grow the size of vm=
linux
> file, with a block of 4096 nul bytes.
=2E..
> Maybe with current machines/boot loaders, we dont care anymore, I don=
t
> know...

Good q.  If people care about on-disk size, maybe we should look at bzI=
mage=20
size?

Anyway, here 'tis:
Before:
  text    data     bss     dec     hex filename
4116153  433292  475136 5024581  4cab45 vmlinux
-rw-r--r-- 1 rusty rusty 2251984 2008-11-19 02:03 arch/x86/boot/bzImage

After:
   text    data     bss     dec     hex filename
4116089  437388  475136 5028613  4cbb05 vmlinux
-rw-r--r-- 1 rusty rusty 2252016 2008-11-19 02:05 arch/x86/boot/bzImage

Cheers,
Rusty.
