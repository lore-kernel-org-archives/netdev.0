From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2] bridge: make it possible for packets to
 traverse the bridge without hitting netfilter
Date: Fri, 06 Mar 2015 12:49:30 -0500 (EST)
Message-ID: <20150306.124930.216237089666857656.davem@davemloft.net>
References: <54EEF32D.2010202@amazon.de>
	<20150226.113431.238255529591339000.davem@davemloft.net>
	<54F982B5.90108@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, imrep@amazon.de, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, fw@strlen.de,
	linux-kernel@vger.kernel.org, aliguori@amazon.com
To: imrep.amz@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <54F982B5.90108@gmail.com>
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

From: Imre Palik <imrep.amz@gmail.com>
Date: Fri, 06 Mar 2015 11:34:29 +0100

> Removed those pieces of the packet pipeline that I don't necessarily
> need one-by-one.  Then measured their effect on small packet
> performance.
> 
> This was the only part that produced considerable effect.
> 
> The pure speculation was about why the effect is more than 15%
> increase in packet throughput, although the code path avoided
> contains way less code than 15% of the packet pipeline.  It seems,
> Felix Fietkau profiled similar changes, and found my guess well
> founded.

Yes and that's the part being left out, the "why".

That's part of what I expect in the justification.

Look, we're not doing things this way.  We need to find a clean
and generic way to make the netfilter hooks as cheap as possible
when netfilter rules are not in use.
