From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net:Kconfig: drop no sense dependence entry for BONDING
Date: Thu, 12 Mar 2015 10:30:44 -0700
Message-ID: <1426181444.11398.167.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150312135933.GA3502@udknight>
	 <5969250.CkvXFhddBO@tacticalops>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wang YanQing <udknight@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-kbuild@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	Erik Hugne <erik.hugne@ericsson.com>
To: Martin Walch <walch.martin@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5969250.CkvXFhddBO@tacticalops>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-03-12 at 16:14 +0100, Martin Walch wrote:
> On Thursday 12 March 2015 21:59:33 Wang YanQing wrote:
> > "IPV6 || IPV6=n" means no dependence!
> 
> IPV6 and BONDING are both tristate symbols and therefore this is not the same
> as no dependency. When setting IPV6 to m, the expression evaluates to
> 
> "IPV6 || IPV6=n" 
> "m || m=n"
> "m || n"
> "m"
> 
> So, if IPV6=m, then BONDING can only be n or m, but not y.

Right.

But it looks like bonding driver no longer has IPV6 dependencies.

Patch should work, but the changelog should be changed to explain why
the patch is valid, and this should be tested.

Presumably we need to make sure the following builds and runs properly

CONFIG_BONDING=y
CONFIG_IPV6=m
