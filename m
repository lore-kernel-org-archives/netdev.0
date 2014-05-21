From: David Miller <davem@davemloft.net>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0
 (bridge : Sanitize skb before it enters the IP stack)
Date: Wed, 21 May 2014 16:14:48 -0400 (EDT)
Message-ID: <20140521.161448.716446182526388511.davem@davemloft.net>
References: <537A12EA.4060604@davidnewall.com>
	<14456.1400561749@turing-police.cc.vt.edu>
	<537C5F71.6000204@davidnewall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, fw@strlen.de,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org
To: davidn@davidnewall.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <537C5F71.6000204@davidnewall.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: David Newall <davidn@davidnewall.com>
Date: Wed, 21 May 2014 17:40:25 +0930

> On 20/05/14 14:25, Valdis.Kletnieks@vt.edu wrote:
>> So yes, we*do* need to do something sensible there - either frag the
>> packet
>> on the way out, or something.
> 
> I think the problem is that a bridge cannot be used across
> incompatible media.  That's the job of a router.
> 
> A bridge should act like a bridge, not a router.  Fragmenting the
> packet is wrong; that's IP's job.  Dropping the packet is also
> arguably wrong; that's the real device-driver's job.  What seems right
> to me is to act like a bridge and forward packets by looking inside of
> them *no more than is necessary*.  Looking beyond MAC address is
> perhaps too much.
> 
> We can finish the job of processing IP options, or at least in this
> scenario, but that seems wrong-headed and invites more work as more
> problems are discovered; or we could remove the half-hearted attempt
> it currently does and leave the bridge as a simple bridge.
> 
> This problem wouldn't occur if all devices in a bridge were required
> to be compatible media; particularly identical MTU.

I completely agree with you.

I also just want to state for the record, and I know some people will
disagree with me, that I think the bridging netfilter layer should
never have been integrated into the tree.

And I've been saying this for more than a decade.

It takes layering violations to a whole new level, and it's why we see
problems like this.

Besides this IP options issue, it also creates fake ipv4 routes, so
every time someone tries to do anything non-trivial with the ipv4
routing code the bridging netfilter fake route code had to be adjusted
or else we'd get crashes.

It has also held back many potential improvements to iptables in
general over the years because it does so many things differently
than the rest of the iptables modules.

It stinks, we never should have added it, and now since we have people
have been perversely convinced that doing stuff like this is actually
sane.  It's not.
