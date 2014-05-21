From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Wed, 21 May 2014 17:40:25 +0930
Message-ID: <537C5F71.6000204@davidnewall.com>
References: <537621AC.1060409@davidnewall.com> <5379FFFD.1050705@davidnewall.com> <20140519140119.GA24523@breakpoint.cc>            <537A12EA.4060604@davidnewall.com> <14456.1400561749@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14456.1400561749@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/05/14 14:25, Valdis.Kletnieks@vt.edu wrote:
> So yes, we*do*  need to do something sensible there - either frag the packet
> on the way out, or something.

I think the problem is that a bridge cannot be used across incompatible 
media.  That's the job of a router.

A bridge should act like a bridge, not a router.  Fragmenting the packet 
is wrong; that's IP's job.  Dropping the packet is also arguably wrong; 
that's the real device-driver's job.  What seems right to me is to act 
like a bridge and forward packets by looking inside of them *no more 
than is necessary*.  Looking beyond MAC address is perhaps too much.

We can finish the job of processing IP options, or at least in this 
scenario, but that seems wrong-headed and invites more work as more 
problems are discovered; or we could remove the half-hearted attempt it 
currently does and leave the bridge as a simple bridge.

This problem wouldn't occur if all devices in a bridge were required to 
be compatible media; particularly identical MTU.
