From: Patrick McHardy <kaber@trash.net>
Subject: Re: bridge+netfilter broken for IP fragments in 2.6.16?
Date: Mon, 03 Apr 2006 01:11:46 +0200
Message-ID: <44305A32.1010109@trash.net>
References: <20060401143011.GA28333@swan.nt.tuwien.ac.at>
	<443023C2.6020401@trash.net>
	<20060402225625.GA22612@swan.nt.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Thomas Zeitlhofer <thomas.zeitlhofer@nt.tuwien.ac.at>
In-Reply-To: <20060402225625.GA22612@swan.nt.tuwien.ac.at>
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

Thomas Zeitlhofer wrote:
> On Sun, Apr 02, 2006 at 09:19:30PM +0200, Patrick McHardy wrote:
> 
>>>Doing the same on 2.6.15.x shows:
>>>
>>>  1) on tap1: fragmented packets
>>>  2) on br0: the defragmented packet (connection tracking)
>>>  3) on eth1: fragmented packets
>>
>>Are you sure this is correct? I think in 2.6.15 you should see
>>the fragments on br0 already.
> 
> 
> Just verified it, at least in 2.6.15.6 tcpdump shows the defragmented
> packet on br0.

I'm probably missing something, but that still seems stange.
Are you also seeing the defragmented packet on br0 with my
patch?

>>Anyway, since 2.6.16 ip_conntrack doesn't do refragmentation anymore
>>but relies on fragmentation in the IP layer. Purely bridged packets
>>don't go through the IP layer, so the bridge netfilter code needs to
>>take care of fragmentation itself. Please try if this patch helps.
> 
> 
> Your patch solves the problem - tcpdump now shows the refragmented
> packets on eth1. Thanks for the quick solution.
> 
> Just a note, your patch does not work when bridge is compiled as a
> module. In this case modprobe failes with "bridge: Unknown symbol
> ip_fragment". Using CONFIG_BRIDGE=y works.

Thanks, I missed that the Makefile adds br_netfilter.o to
bridge-$(CONFIG_BRIDGE_NETFILTER), not obj-$(...).
