From: walter harms <wharms@bfs.de>
Subject: Re: [patch -next v2] mv643xx_eth: potential null dereference
Date: Sat, 24 Jul 2010 10:59:07 +0200
Message-ID: <4C4AAB5B.2050901@bfs.de>
References: <20100723101528.GF26313@bicker> <1279881177.24768.1623.camel@Joe-Laptop.home> <20100723110504.GG26313@bicker> <4C49C39E.8020502@bfs.de> <20100723221514.GJ26313@bicker>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Saeed Bishara <saeed@marvell.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:57432 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625Ab0GXI7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jul 2010 04:59:10 -0400
In-Reply-To: <20100723221514.GJ26313@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Carpenter schrieb:
> On Fri, Jul 23, 2010 at 06:30:22PM +0200, walter harms wrote:
>> this is a bit complicated, IMHO ppl have a bigger chance to discover what is going on
>> with this version:
>>
>>     if (!pd ) {
>>        msp->t_clk = 133000000;
>>        msp->tx_csum_limit = 9 * 1024;
>>      }
>>      else
>>       {
>> 	msp->t_clk = pd->t_clk ? pd->t_clk : 133000000 ;
>>         msp->tx_csum_limit = pd->tx_csum_limit ? pd->tx_csum_limit : 9 * 1024;
>>        }
>>
> 
> But then instead of 2 magic numbers we would have 4. :/
> 

Yes it can be shorten,

msp->t_clk = 133000000;
msp->tx_csum_limit = 9 * 1024;
if (pd) {
	if (pd->t_clk) msp->t_clk = pd->t_clk ;
	if (pd->tx_csum_limit) sp->tx_csum_limit = pd->tx_csum_limit;
}
pd->t_clk
i was thinking about that in my first posting but i have the feeling that ppl
tend to overlook the "if (pd)" but in this case it is important since the
behavier is different.

IMHO it would be better to make sure that pd->t_clk,pd->tx_csum_limit have usefull
values than adding a check but this is up to the maintainer.

re,
 wh

