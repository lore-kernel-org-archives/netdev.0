From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: inetfilter: LLVMLinux: vlais-netfilter
Date: Fri, 7 Mar 2014 18:26:27 +0100
Message-ID: <20140307172627.GA4856@localhost>
References: <1394135768-27621-1-git-send-email-behanw@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	dwmw2@infradead.org, pageexec@freemail.hu,
	Mark Charlebois <charlebm@gmail.com>,
	=?iso-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti@gmail.com>
To: behanw@converseincode.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394135768-27621-1-git-send-email-behanw@converseincode.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 06, 2014 at 11:56:08AM -0800, behanw@converseincode.com wrote:
> From: Mark Charlebois <charlebm@gmail.com>
> 
> Replaced non-standard C use of Variable Length Arrays In Structs (VLAIS) in
> xt_repldata.h with a C99 compliant flexible array member and then calculated
> offsets to the other struct members. These other members aren't referenced by
> name in this code, however this patch maintains the same memory layout and
> padding as was previously accomplished using VLAIS.
> 
> Had the original structure been ordered differently, with the entries VLA at
> the end, then it could have been a flexible member, and this patch would have
> been a lot simpler. However since the data stored in this structure is
> ultimately exported to userspace, the order of this structure can't be changed.
> 
> This patch makes no attempt to change the existing behavior, merely the way in
> which the current layout is accomplished using standard C99 constructs. As such
> the code can now be compiled with either gcc or clang.

I think we already agreed on not accepting macro tricks to get this
compiling with clang:

http://comments.gmane.org/gmane.comp.security.firewalls.netfilter.devel/45138
