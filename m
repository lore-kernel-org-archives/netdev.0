From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [RFC PATCH] bgmac: Fix build error seen if BCM47XX is not configured
Date: Wed, 15 Apr 2015 22:21:49 +0200
Message-ID: <CACna6rwPYP0FV60v9ey0uV=3eU_8SZ4t+WoZCtiDHHeCLiM3Dg@mail.gmail.com>
References: <1429128338-28549-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
To: Guenter Roeck <linux@roeck-us.net>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35613 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbbDOUVu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 16:21:50 -0400
In-Reply-To: <1429128338-28549-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 April 2015 at 22:05, Guenter Roeck <linux@roeck-us.net> wrote:
> arm:allmodconfig fails to build as follows since ARCH_BCM_5301X
> is configured but not BCM47XX.
>
> drivers/net/ethernet/broadcom/bgmac.c: In function 'bgmac_probe':
> drivers/net/ethernet/broadcom/bgmac.c:1643:2: error:
>                 implicit declaration of function 'bcm47xx_nvram_geten=
v'
>
> Fixes: fc300dc3733f ("bgmac: allow enabling on ARCH_BCM_5301X")
> Cc: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> Seen in today's upstream kernel.
>
> I don't like this fix too much (I think it is quite kludgy),
> so I marked it RFC (and please don't beat the messenger ;-).

Ooh great, I totally forgot about this :|

The problem is that fc300dc (bgmac: allow enabling on ARCH_BCM_5301X)
[0] shouldn't really be sent (by me) in the first place. This is
because it depends on 138173d (MIPS: BCM47xx: Move NVRAM header to the
include/linux/.) [1] which isn't in Linus's tree yet.

So there are two solutions:
1) Revert fc300dc, wait for 138173d and re-apply fc300dc
2) Wait for 138173d with this build breakage

I guess the decisions depends on
a) time needed for David to revert fc300dc & send pull request
vs.
b) time needed for Ralf to send pull request

David, Ralf, what do you think about this?

Sorry for causing this problem :|

[0] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3Dfc300dc3733fdc328e6e10c7b8379b60c26cd648
[1] http://git.linux-mips.org/cgit/ralf/upstream-sfr.git/commit/?id=3D1=
38173d4e826587da66c7d321da1a91283222536
