From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: randconfig build error with next-20140113, in net/netfilter/nft_reject.c
Date: Mon, 13 Jan 2014 13:12:49 -0500
Message-ID: <CAP=VYLqWGjOnH0uw_=JDYEy2p-V5a0y3DvfuNGi600ZVPgVjRA@mail.gmail.com>
References: <CA+r1Zhjqrmm8a9fVsjfXamCE1qQq=YBexpeU95ODi=BiSie7aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo@netfilter.org,
	Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35104 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbaAMSNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 13:13:21 -0500
In-Reply-To: <CA+r1Zhjqrmm8a9fVsjfXamCE1qQq=YBexpeU95ODi=BiSie7aA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 8:51 AM, Jim Davis <jim.epost@gmail.com> wrote:
> Building with the attached random configuration file,
>
> warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet
> direct dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
> warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet
> direct dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
>
>   LD      init/built-in.o
> net/built-in.o: In function `nft_reject_eval':
> nft_reject.c:(.text+0x67bc1): undefined reference to `nf_ip6_checksum'
> nft_reject.c:(.text+0x67c28): undefined reference to `ip6_route_output'
> nft_reject.c:(.text+0x67d09): undefined reference to `ip6_dst_hoplimit'
> make: *** [vmlinux] Error 1

I came across the same thing independently while working on an
unrelated netfilter patch.  Bisected and fix sent.

http://patchwork.ozlabs.org/patch/310298/
