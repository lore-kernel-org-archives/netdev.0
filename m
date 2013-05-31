From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: skbuff: use _RET_IP_
Date: Fri, 31 May 2013 09:54:52 -0700
Message-ID: <1370019292.10556.79.camel@joe-AO722>
References: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
	 <51A6768B.5050603@cogentembedded.com> <87obbsohd1.fsf@nemi.mork.no>
	 <1369962688.1751.6.camel@buesod1.americas.hpqcorp.net>
	 <1369977659.10556.34.camel@joe-AO722> <51A8B4A4.1010204@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45703 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751977Ab3EaQyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 12:54:52 -0400
In-Reply-To: <51A8B4A4.1010204@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-31 at 18:33 +0400, Sergei Shtylyov wrote:
> On 31-05-2013 9:20, Joe Perches wrote:
> > Don't use a standalone gcc compiled program to
> > determine what the kernel outputs.
[]
> > The kernel output is;
> 
> > 	printk("0x%lx\n", 0x100ul)		0x100
> > 	printk("%p\n", (void *)0x100ul)		00000100
> > 	printk("%#p\n", (void *)0x100ul)	0x00000100
> 
> > The last one isn't used at all in kernel source. (gcc complains)
> > It's always "0x%p"
> 
>      I was talking about using "%#lx", not "%#p". I don't see it in your 
> example.

"0x%lx" and "%#lx" produce the same output in the kernel.

The latter isn't used very often though.
I expect most coders don't know it exists/works.

$ git grep -E "0x%l{0,2}x" | wc -l
12542
$ git grep -E "%#l{0,2}x" | wc -l
1737

(some false positives there of course)

Also, some might expect that "%#08lx", is 10 chars wide,
but it's only 8, so maybe "0x%08lx" is better used.

The "%#08lx" width defect seems pretty common:

$ git grep -E -i "%#0(8|16)l{0,2}x" | wc -l
253
