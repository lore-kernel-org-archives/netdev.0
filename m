From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: [IPSEC]: Use the correct ip_local_out function
Date: Tue, 20 May 2008 12:18:16 +0200
Message-ID: <BAY103-DAV10610255819F634BC984ABB2C40@phx.gbl>
References: <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl> <20080512074642.GA1416@gondor.apana.org.au> <BAY103-DAV521435E26209347B7646FB2CC0@phx.gbl> <BAY103-DAV2A04E519F35401C98403FB2CC0@phx.gbl> <BAY103-DAV20B0EEFFB30A41A8020C8B2CC0@phx.gbl> <BAY103-DAV88950FC99CDE9EAAE27B2B2CE0@phx.gbl> <20080520092511.GA9005@gondor.apana.org.au>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s14.bay0.hotmail.com ([65.54.246.150]:54861 "EHLO
	bay0-omc2-s14.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762352AbYETKVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 06:21:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> On Wed, May 14, 2008 at 10:19:57AM +0200, Marco Berizzi wrote:
> >
> > I hope this helps.
>
> OK found the problem, it was my fault after all :)
>
> Dave, this patch needs to go into stable too.
>
> [IPSEC]: Use the correct ip_local_out function
>
> Because the IPsec output function xfrm_output_resume does its
> own dst_output call it should always call __ip_local_output
> instead of ip_local_output as the latter may invoke dst_output
> directly.  Otherwise the return values from nf_hook and dst_output
> may clash as they both use the value 1 but for different purposes.
>
> When that clash occurs this can cause a packet to be used after
> it has been freed which usually leads to a crash.  Because the
> offending value is only returned from dst_output with qdiscs
> such as HTB, this bug is normally not visible.
>
> Thanks to Marco Berizzi for his perseverance in tracking this
> down.

Herbert,
many many thanks to you for fixing this bug.
I was going on with git bisect, but I was not
able anymore to reproduce the bug after four
git bisect step.
I'm going to apply immediately your patch to
2.6.25.4
Just for record, this is my last git bisect log:
root@Venus:/tmp/GIT/my2.6.25.y# git bisect log
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
# good: [8e8c71f1ab0ca1c4e74efad14533b991524dcb6c] [DCCP]: Honour and
make use of shutdown option set by user
git-bisect good 8e8c71f1ab0ca1c4e74efad14533b991524dcb6c
# good: [dd88590995de7c7ce108718a9ad52b3832e77814] [DECNET]: Remove
extra memset from dn_fib_check_nh
git-bisect good dd88590995de7c7ce108718a9ad52b3832e77814


