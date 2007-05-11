From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tbf scheduler: TSO support
Date: Fri, 11 May 2007 03:04:21 +0200
Message-ID: <4643C115.3020802@trash.net>
References: <20070510.210556.05145104.taka@valinux.co.jp>	<46431687.7060600@trash.net> <20070510.141344.127196214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: taka@valinux.co.jp, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070510.141344.127196214.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 10 May 2007 14:56:39 +0200
> 
>>I don't see why this is needed, the correct way to use TBF with TSO
>>is to specify a larger MTU value, in which case it won't drop TSO
>>packets.
> 
> 
> Why should a user have to know anything in the world about TSO in
> order to configure TBF properly?  I don't think they should have
> to at all.


The user shouldn't necessarily, but userspace should.
The way I see it the MTU is a fundamental parameter for TBF
(the peakrate bucket size) and just because userspace picks
a bad default (2000) this is no reason to change the
implementation to something that is not really TBF anymore
and even affects non-TSO packets _and_ TSO packets even
when the MTU is chosen large enough (granted, the first
point is an implementation detail). The much better solution
would be to let userspace pick an appropriate default value
and still let the user override it.
