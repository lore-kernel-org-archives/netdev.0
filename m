From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH 2/3] netfilter : 3 patches to boost ip_tables performance
Date: Fri, 23 Sep 2005 06:02:34 +0200
Message-ID: <20050923040234.GC595@alpha.home.local>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
	<432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de>
	<433082DE.3060308@cosmosbay.com> <43308324.70403@cosmosbay.com>
	<4331D168.6090604@cosmosbay.com>
	<20050922124803.GH26520@sunbeam.de.gnumonks.org>
	<4332AC2E.8000607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <4332AC2E.8000607@cosmosbay.com>
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

On Thu, Sep 22, 2005 at 03:05:50PM +0200, Eric Dumazet wrote:
(...) 
> It was necessary to get the best code with gcc-3.4.4 on i386 and 
> gcc-4.0.1 on x86_64
> 
> For example :
> 
> bool1 = FWINV(ret != 0, IPT_INV_VIA_OUT);
> if (bool1) {
> 
> gives a better code than :
> 
> if (FWINV(ret != 0, IPT_INV_VIA_OUT)) {
> 
> (one less conditional branch)
> 
> Dont ask me why, it is shocking but true :(

I also noticed many times that gcc's optimization of "if (complex condition)"
is rather poor and it's often better to put it in a variable before. I even
remember that if you use an intermediate variable, it can often generate a
CMOV instruction on processors which support it, while it produces cond tests
and jumps without the variable. Generally speaking, if you want fast code,
you have to write it as a long sequence of small instructions, just as if
you were writing assembly. As you said, shocking but true.

BTW, cheers for your optimizations !

Regards,
Willy
