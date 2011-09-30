From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Fri, 30 Sep 2011 11:49:22 +0900
Message-ID: <4E852E32.6090703@renesas.com>
References: <20110930113811.c2fa2d532dfa799a49c146f4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Paul Mundt <lethal@linux-sh.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:44451 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab1I3CtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 22:49:24 -0400
In-reply-to: <20110930113811.c2fa2d532dfa799a49c146f4@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Thank you for the report.
I will submit a patch for the issue soon.
Since I used the net-next.git, the build failure didn't happen.
This is because that the linux/device.h of the net-next.git has "#include <linux/module.h>".
But, I was wrong to remove "#include <linux/module.h>" in the sh_eth.{c,h}.

Thanks,
Yoshihiro Shimoda

2011/09/30 10:38, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the final tree, the next-20110929 build (various sh configs)
> failed like this:
> 
> drivers/net/ethernet/renesas/sh_eth.c:601: error: 'THIS_MODULE' undeclared here (not in a function)
> drivers/net/ethernet/renesas/sh_eth.c:1970: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/renesas/sh_eth.c:1970: warning: data definition has no type or storage class
> drivers/net/ethernet/renesas/sh_eth.c:1970: warning: type defaults to 'int' in declaration of 'MODULE_AUTHOR'
> drivers/net/ethernet/renesas/sh_eth.c:1970: warning: function declaration isn't a prototype
> drivers/net/ethernet/renesas/sh_eth.c:1971: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/renesas/sh_eth.c:1971: warning: data definition has no type or storage class
> drivers/net/ethernet/renesas/sh_eth.c:1971: warning: type defaults to 'int' in declaration of 'MODULE_DESCRIPTION'
> drivers/net/ethernet/renesas/sh_eth.c:1971: warning: function declaration isn't a prototype
> drivers/net/ethernet/renesas/sh_eth.c:1972: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/renesas/sh_eth.c:1972: warning: data definition has no type or storage class
> drivers/net/ethernet/renesas/sh_eth.c:1972: warning: type defaults to 'int' in declaration of 'MODULE_LICENSE'
> drivers/net/ethernet/renesas/sh_eth.c:1972: warning: function declaration isn't a prototype
> 
> Presumbly revealed by the module.h split up.  This file needs to include module.h.
