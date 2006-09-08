From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 data corruption (TSO ?)
Date: Fri, 08 Sep 2006 12:54:16 -0700
Message-ID: <1157745256.5344.8.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC093FB19@NT-IRVA-0751.brcm.ad.broadcom.com>
 <9EAEC3B2-260E-444E-BCA1-3C9806340F65@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Linux Kernel list" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2055 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S1751122AbWIHT4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 15:56:17 -0400
To: "Segher Boessenkool" <segher@kernel.crashing.org>
In-Reply-To: <9EAEC3B2-260E-444E-BCA1-3C9806340F65@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-08 at 21:29 +0200, Segher Boessenkool wrote:

> I've got a patch that seems so solve the problem, it needs more testing
> though (maybe Ben can do this :-) ).  The problem is that there should
> be quite a few wmb()'s in the code that are just not there; adding some
> to tg3_set_txd() seems to fix the immediate problem but more is needed
> (and I don't see why those should be needed, unless tg3_set_txd() is
> updating a life ring entry in place or something like that).
> 
> More testing is needed, but the problem is definitely the lack of memory
> ordering.
> 
Oh, we know about this.  The powerpc writel() used to have memory
barriers in 2.4 kernels but not any more in 2.6 kernels.  Red Hat's
version of tg3 has extra wmb()'s to fix this problem.  David doesn't
think that the upstream version of tg3 should have these wmb()'s, and
the problem should instead be fixed in powerpc's writel().

