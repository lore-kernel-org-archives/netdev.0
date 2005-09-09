From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Fri, 09 Sep 2005 13:41:34 +0200
Message-ID: <432174EE.80306@trash.net>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907205923.GA6567@schmorp.de>
	<431F5CD2.8020905@trash.net> <20050907215213.GB8222@schmorp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Marc Lehmann <schmorp@schmorp.de>
In-Reply-To: <20050907215213.GB8222@schmorp.de>
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

Marc Lehmann wrote:
> It's also a 64-bit-only problem. To verify, I tried this:
> 
> ethtool -K eth1 rx off tx off sg off
> 
> Where eth1 is the interface where pppoe runs over.
> 
> ethtool -k eth1 then displayed:
> 
>    rx-checksumming: off
>    tx-checksumming: off
>    scatter-gather: off
>    tcp segmentation offload: off
> 
> And ICMP, TCP etc. starts working again.
> 
> Thanks for the analysis and the hint, I guess that verifies that its hw
> checksumming. (Weird that hw checksumming on the underlying device somehow
> changes the ppp packets, but nevertheless).

I tried reproducing the problem without any luck. Its odd that its
happening on both eth and ppp devices, if it was just ppp I would
suspect some missing checksum update/invalidation in the ppp driver.
What network driver are you using? Please also send a list of loaded
modules and iptables rules. Thanks.
