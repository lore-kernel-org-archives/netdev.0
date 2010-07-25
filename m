From: walter harms <wharms@bfs.de>
Subject: Re: [patch -next v2] mv643xx_eth: potential null dereference
Date: Sun, 25 Jul 2010 16:47:17 +0200
Message-ID: <4C4C4E75.4080603@bfs.de>
References: <20100723101528.GF26313@bicker> <1279881177.24768.1623.camel@Joe-Laptop.home> <20100723110504.GG26313@bicker> <4C49C39E.8020502@bfs.de> <20100723221514.GJ26313@bicker> <4C4AAB5B.2050901@bfs.de> <20100724190036.GA21121@mail.wantstofly.org>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <error27@gmail.com>, Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Saeed Bishara <saeed@marvell.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:45893 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab0GYOrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jul 2010 10:47:20 -0400
In-Reply-To: <20100724190036.GA21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Lennert Buytenhek schrieb:
> On Sat, Jul 24, 2010 at 10:59:07AM +0200, walter harms wrote:
> 
>> IMHO it would be better to make sure that pd->t_clk,pd->tx_csum_limit
>> have usefull values than adding a check but this is up to the maintainer.
> 
> I don't see the point of that at all.  We check against zero to see
> whether the caller bothered to fill in the field at all, but if the
> caller wants to pass in bogus values, that's up to the caller.
> 
at first i have to admit i looked only at the patch.
for me the situation looks this way:

You check the values for 0 (and uses default) or take what ever in pd is.
The current code is setup like:

  1. check if pd is set
  2. check if pd->value is non zero and use it

the whole "check X" can be avoided if you could create a pd with all values
set to default and just take what comes from the user.

my objection agains this kind of code is that it is not obvious
what some one is trying to archive
(pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;

the pd check means: do i have a configuration  ?
the pd->t_clk != 0 means: should i use then or default ?

This is mixing two very different questions. therefore my idea in the last
posting to have a default init if (!pd) and then use the else to make clear
that additional checks for pd->value are expected.

this this is the init code readability and simplicity should be king.

hope that helps,
re,
 wh


