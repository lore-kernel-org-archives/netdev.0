From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: turn NF_HOOK into an inline function
Date: Fri, 16 Oct 2015 18:45:27 +0200
Message-ID: <20151016164527.GA3601@salvia>
References: <7665226.mEs2QJDTOT@wuerfel>
 <87zizryjzs.fsf@x220.int.ebiederm.org>
 <5713169.GvahoqQ9XY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35077 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186AbbJPQiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 12:38:24 -0400
Content-Disposition: inline
In-Reply-To: <5713169.GvahoqQ9XY@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2015 at 08:45:42PM +0200, Arnd Bergmann wrote:
> A recent change to the dst_output handling caused a new warning
> when the call to NF_HOOK() is the only used of a local variable
> passed as 'dev', and CONFIG_NETFILTER is disabled:
> 
> net/ipv6/ip6_output.c: In function 'ip6_output':
> net/ipv6/ip6_output.c:135:21: warning: unused variable 'dev' [-Wunused-variable]
> 
> The reason for this is that the NF_HOOK macro in this case does
> not reference the variable at all, and the call to dev_net(dev)
> got removed from the ip6_output function. To avoid that warning now
> and in the future, this changes the macro into an equivalent
> inline function, which tells the compiler that the variable is
> passed correctly but still unused.
> 
> The dn_forward function apparently had the same problem in
> the past and added a local workaround that no longer works
> with the inline function. In order to avoid a regression, we
> have to also remove the #ifdef from decnet in the same patch.

Applied, thanks.
