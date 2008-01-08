From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 8 Jan 2008 08:14:01 -0800
Message-ID: <20080108081401.d9576ac5.randy.dunlap@oracle.com>
References: <477FF149.4070609@linux.intel.com>
	<20080105213935.GN27894@ZenIV.linux.org.uk>
	<20080107174431.GC27741@fieldses.org>
	<4782CF9C.6000508@gmail.com>
	<alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19167 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760028AbYAHQOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 11:14:46 -0500
In-Reply-To: <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jan 2008 19:26:12 -0800 (PST) Linus Torvalds wrote:

> On Mon, 7 Jan 2008, Kevin Winchester wrote:
> 
> > J. Bruce Fields wrote:
> > > 
> > > Is there any good basic documentation on this to point people at?
> > 
> > I would second this question.  I see people "decode" oops on lkml often 
> > enough, but I've never been entirely sure how its done.  Is it somewhere 
> > in Documentation?
> 
> It's actually not necessarily at all that trivial, unless you have a deep 
> understanding of the code generated for the architecture in question (and 
> even then, some oopses take more time to figure out than others, thanks 
> to inlining and tailcalls etc).
> 
> If the oops happened with a kernel you generated yourself, it's usually 
> rather easy. Especially if you said "y" to the "generate debugging info" 
> question at configuration time. Because, in that case, you really just do 
> a simple
> 
> 	gdb vmlinux
> 
> and then you can do (for example) something like setting a breakpoint at 
> the EIP that was reported for the oops, and it will tell you what line it 
> came from.
> 
> However, if you don't have the exact binary - which is the common case for 
> random oopses reported on lkml - you will generally have to disassemble 
> the hex sequence given in the oops (the "Code:" line), and try to match it 
> up against the source code to try to figure out what is going on.
> 
> Even just the disassembly is not entirely trivial, since the oops will 
> give you the eip that it happened at, but you often want to also 
> disassemble *backwards* in order to get more of a context (the "Code:" 
> line will mark the particular EIP that starts the oopsing instruction by 
> enclosing it in <xx>, but with non-constant instruction lengths, you need 
> to use a bit of trial-and-error to figure it out.
> 
> I usually just compile a small program like
> 
> 	const char array[]="\xnn\xnn\xnn...";
> 
> 	int main(int argc, char **argv)
> 	{
> 		printf("%p\n", array);
> 		*(int *)0=0;
> 	}
> 
> and run it under gdb, and then when it gets the SIGSEGV (due to the 
> obvious NULL pointer dereference), I can just ask gdb to disassemble 
> around the array that contains the code[] stuff. Try a few offsets, to see 
> when the disassembly makes sense (and gives the reported EIP as the 
> beginning of one of the disassembled instructions).
> 
> (You can do it other and smarter ways too, I'm not claiming that's a 
> particularly good way to do it, and the old "ksymoops" program used to do 
> a pretty good job of this, but I'm used to that particular idiotic way 
> myself, since it's how I've basically always done it)

One other way to do it (at least for x86-32/64) is to use
$kerneltree/scripts/decodecode.  It may work on other $arches also,
but I haven't tested it on others.

---
~Randy
