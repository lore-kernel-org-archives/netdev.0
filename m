From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Wed, 27 Apr 2005 14:05:06 +0200
Message-ID: <426F7FF2.4070506@trash.net>
References: <426D8672.1030001@trash.net>
	<20050426003925.GA13650@gondor.apana.org.au>
	<426E3F67.8090006@trash.net>
	<20050426232857.GA18358@gondor.apana.org.au>
	<426EE350.1070902@trash.net>
	<20050427010730.GA18919@gondor.apana.org.au>
	<426F68C5.4010109@trash.net>
	<20050427103056.GB22099@gondor.apana.org.au>
	<Pine.LNX.4.58.0504271237350.4795@blackhole.kfki.hu>
	<20050427113542.GB22433@gondor.apana.org.au>
	<20050427115414.GA22562@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, Yair@arx.com,
	linux-kernel@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050427115414.GA22562@gondor.apana.org.au>
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
> Here is another reason why these packets should go through FORWARD.
> They were generated in response to packets in INPUT/FORWARD/OUTPUT.
> The original packet has not undergone SNAT in any of these cases.
> 
> However, if we feed the response packet through LOCAL_OUT it will
> be subject to DNAT.  This creates a NAT asymmetry and we may end
> up with the wrong destination address.
> 
> By pushing it through FORWARD it will only undergo SNAT which is
> correct since the original packet would have undergone DNAT.

This is only a problem since the recent NAT changes, but I agree
that we should fix it by moving these packets to FORWARD.

Regards
Patrick
