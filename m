From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 13:57:48 +0200
Message-ID: <42FC8EBC.1070505@trash.net>
References: <20050811200349.GN5353@rama.de.gnumonks.org>	<20050811.154204.102613246.davem@davemloft.net>
	<p73u0hv2xkv.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <p73u0hv2xkv.fsf@verdi.suse.de>
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

Andi Kleen wrote:
> "David S. Miller" <davem@davemloft.net> writes:
>>
>>Won't work in x86 --> x86_64 compat environments.
> 
> Thanks for catching it.
> 
> The aligned u64 trick probably will
> 
> #define aligned_u64 unsigned long long __attribute__((aligned(8)))
> 
> It just forces i386 to be aligned too.
> 
> Then use aligned_u64 instead of u64/__u64/u_int64_t in all user visible 
> places. Similar for signed types.

Unfortunately one of the iptables structures which is needed to get the
ruleset in the kernel (ipt_replace) is differently sized when compiled
for 32/64 bit. IIRC it doesn't work at all currently.
