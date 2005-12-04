From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Sun, 04 Dec 2005 23:49:02 +0100
Message-ID: <4393725E.7070604@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163135.16666.76993.sendpatchset@localhost.localdomain>
	<20051201012711.GA2527@gondor.apana.org.au>
	<4393684A.8030208@trash.net>
	<20051204221002.GA17056@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051204221002.GA17056@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sun, Dec 04, 2005 at 11:06:02PM +0100, Patrick McHardy wrote:
> 
> If there is a DNAT in the way, this will jump to the very start of
> the stack.  So if we have a hostile IPsec peer, and the DNAT rules
> are such that this can occur, then we could be in trouble (especially
> because policy/selector verification does not occur until all IPsec
> has been done so we can't check inner address validitiy at this point).

We could return NET_XMIT_BYPASS from ip_xfrm_transport_hook(), although
it looks a bit ugly to use NET_XMIT* on the input path.
