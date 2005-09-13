From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: masquerading failure for at least icmp and tcp+sack on amd64
Date: Tue, 13 Sep 2005 11:09:02 -0700
Message-ID: <20050913110902.0ad58b90@localhost.localdomain>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907205923.GA6567@schmorp.de>
	<431F5CD2.8020905@trash.net> <20050907215213.GB8222@schmorp.de>
	<432174EE.80306@trash.net> <20050911131943.GC9865@schmorp.de>
	<43243AB9.9000705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Marc Lehmann <schmorp@schmorp.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <43243AB9.9000705@trash.net>
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

On Sun, 11 Sep 2005 16:10:01 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Marc Lehmann wrote:
> > On Fri, Sep 09, 2005 at 01:41:34PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> > 
> >>What network driver are you using?
> > 
> > Happens with both skge and sk98.
> 
> Are you sure the same checksum error happens? sk98_lin never sets
> ip_summed to CHECKSUM_HW, it uses either CHECKSUM_UNNECESSARY for
> HW checksummed packets, in which case the check is skipped in
> ip_conntrack, or it uses CHECKSUM_NONE, in which case the checksum
> in the packet must be invalid if the check fails and the packet
> wouldn't be accepted by the final receipient anyway. skge uses 
> CHECKSUM_HW for every packet, so they have nothing in common wrt.
> HW checksumming. This would normally mean we can rule out HW
> checksumming, but for some reason turning it off on skge seems
> to help in your case. Stephen, you're more familiar with the
> sk* drivers than me, anything I'm missing here?
> 

Some background, the semantic of ip_summed is different on the
output than the input path. On input, it means a checksum is
available in skb->csum; and on output it means the packet is
destined for a device that can do hardware checksumming.

I have gotten reports of receive checksum errors on
some systems, it may be related to certain revisions of
hardware. It would be useful to see the message printed out
by the skge driver that shows chip and revision.

Also, on the input path for TCP and UDP, the code does not
depend on the hardware being correct, and if the checksum
is incorrect, it just prints a warning and does a software
checksum before deciding to drop.
Perhaps netfilter code needs to handle that case?
