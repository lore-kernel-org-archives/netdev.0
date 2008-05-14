From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Wed, 14 May 2008 14:03:05 +0200
Message-ID: <BAY103-DAV745BB1E190B27DAD19A19B2CE0@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl> <20080512074642.GA1416@gondor.apana.org.au> <BAY103-DAV521435E26209347B7646FB2CC0@phx.gbl> <BAY103-DAV2A04E519F35401C98403FB2CC0@phx.gbl> <BAY103-DAV20B0EEFFB30A41A8020C8B2CC0@phx.gbl> <BAY103-DAV88950FC99CDE9EAAE27B2B2CE0@phx.gbl>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s26.bay0.hotmail.com ([65.54.246.162]:47902 "EHLO
	bay0-omc2-s26.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757130AbYENMFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 08:05:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

game over :-((

I was going forward with git bisect but now kernel
doesn't compile anymore
  LD      drivers/misc/built-in.o
  CC      drivers/net/Space.o
  CC      drivers/net/loopback.o
In file included from include/net/sock.h:50,
                 from drivers/net/loopback.c:53:
include/linux/pcounter.h: In function 'pcounter_add':
include/linux/pcounter.h:87: error: 'struct pcounter' has no member
named 'value'
make[2]: *** [drivers/net/loopback.o] Error 1
make[1]: *** [drivers/net] Error 2

Here is my git bisect log output:

git-bisect start
# good: [49914084e797530d9baaf51df9eda77babc98fa8] Linux 2.6.24
git-bisect good 49914084e797530d9baaf51df9eda77babc98fa8
# bad: [4b119e21d0c66c22e8ca03df05d9de623d0eb50f] Linux 2.6.25
git-bisect bad 4b119e21d0c66c22e8ca03df05d9de623d0eb50f
# bad: [dd5f5fed6c9458a7aa81eeef3732cc3a9891cfdf] Merge branch
'audit.b46' of
git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
git-bisect bad dd5f5fed6c9458a7aa81eeef3732cc3a9891cfdf
# bad: [fde3571fd8613483f1203d11394ae316c6b79a03] iwlwifi: avoid
firmware command sending if rfkill is enabled
git-bisect bad fde3571fd8613483f1203d11394ae316c6b79a03
# good: [1c7c2cdec3a6b2873439096983794a550d7ff65b] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
git-bisect good 1c7c2cdec3a6b2873439096983794a550d7ff65b
# bad: [4c37799ccf6c722e0dad6a0677af22d1c23fb897] [NETFILTER]: Use
lowercase names for matches in Kconfig
git-bisect bad 4c37799ccf6c722e0dad6a0677af22d1c23fb897
# good: [f4798748dee00c807a63f5518f08b3df161e0f6d] Merge branch
'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/hid
git-bisect good f4798748dee00c807a63f5518f08b3df161e0f6d
# good: [9c55e01c0cc835818475a6ce8c4d684df9949ac8] [TCP]: Splice receive
support.
git-bisect good 9c55e01c0cc835818475a6ce8c4d684df9949ac8


