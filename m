From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Unaligned access on IA64 when comparing ethernet
	addresses
Date: Thu, 19 Apr 2007 11:18:57 -0700
Message-ID: <20070419111857.62241675@dxpl.pdx.osdl.net>
References: <4625BE2C.1030801@sw.ru>
	<20070418.012804.95897126.davem@davemloft.net>
	<20070418074439.1ba41718@localhost.localdomain>
	<20070418.130422.88477383.davem@davemloft.net>
	<20070419161423.a8f5c4f0.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.osdl.org,
        David Miller <davem@davemloft.net>, devel@openvz.org, xemul@sw.ru
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20070419161423.a8f5c4f0.dada1@cosmosbay.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Apr 2007 16:14:23 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> On Wed, 18 Apr 2007 13:04:22 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > 
> > Although I don't think gcc does anything fancy since we don't
> > use memcmp().  It's a tradeoff, we'd like to use unsigned long
> > comparisons when both objects are aligned correctly but we also
> > don't want it to use any more than one potentially mispredicted
> > branch.
> 
> Again, memcmp() *cannot* be optimized, because its semantic is to compare bytes.
> 
> memcpy() can take into account alignement if known at compile time, not memcmp()
> 
> http://lists.openwall.net/netdev/2007/03/13/31

It can if we order bytes in the bridge id properly.  See ktime_t for example.
