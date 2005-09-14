From: Patrick McHardy <kaber@trash.net>
Subject: Re: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 14 Sep 2005 03:10:38 +0200
Message-ID: <4327788E.8030708@trash.net>
References: <20050907052057.09714a4c.akpm@osdl.org>	<431EDF78.8060505@trash.net>	<20050907205923.GA6567@schmorp.de>	<431F5CD2.8020905@trash.net>	<20050907215213.GB8222@schmorp.de>	<432174EE.80306@trash.net>	<20050911131943.GC9865@schmorp.de>	<43243AB9.9000705@trash.net>
	<20050913110902.0ad58b90@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Marc Lehmann <schmorp@schmorp.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050913110902.0ad58b90@localhost.localdomain>
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

Stephen Hemminger wrote:
> Some background, the semantic of ip_summed is different on the
> output than the input path. On input, it means a checksum is
> available in skb->csum; and on output it means the packet is
> destined for a device that can do hardware checksumming.

Yep, so far the netfilter code should be correct since my batch
of HW checksum fixes.

> I have gotten reports of receive checksum errors on
> some systems, it may be related to certain revisions of
> hardware. It would be useful to see the message printed out
> by the skge driver that shows chip and revision.

That may be the reason. I've audited most relevant code-paths
for this case and they seem to be mostly OK. There are a couple
of cases in the ppp code I'm not sure about yet, but I couldn't
trigger any errors in my test-setup. Anyway they don't seem to
be related to this problem since it also happens with sk98_lin
which doesn't set CHECKSUM_HW.

> Also, on the input path for TCP and UDP, the code does not
> depend on the hardware being correct, and if the checksum
> is incorrect, it just prints a warning and does a software
> checksum before deciding to drop.
> Perhaps netfilter code needs to handle that case?

Yes, this is not handled so far. But is looks like there is
some other problem because it also happens with sk98_lin.

Thanks for your help Stephen.
