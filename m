From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 10 Aug 2007 11:19:54 +0200
Message-ID: <20070810091954.GI1764@ff.dom.local>
References: <JMJTMH$F1699B57C9B0E170ED337488612E649B@xandmail.com> <20070810083720.GE1764@ff.dom.local> <20070810084841.GA11086@elte.hu> <20070810090318.GG1764@ff.dom.local> <20070810090833.GA15121@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:47602 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751783AbXHJJTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 05:19:18 -0400
Content-Disposition: inline
In-Reply-To: <20070810090833.GA15121@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 11:08:33AM +0200, Ingo Molnar wrote:
> 
> * Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > On 10-08-2007 10:05, Thomas Gleixner wrote:
> > ...
> > > But suppressing the resend is not fixing the driver problem. The 
> > > problem can show up with spurious interrupts and with interrupts on 
> > > a shared PCI interrupt line at any time. It just might take weeks 
> > > instead of minutes.
> > 
> > Maybe I miss something but it's not the same!
> 
> _now_ i finally understand what you probably meant: because sw-resend 
> worked and hw-resend didnt, it's hw-resend that is causing the breakage, 
> not any driver or irqflow bug - correct?

All correct! There was also checked a possibility it can be not
hw itself, but wrong way of handling after hw (acking too late). This
was false idea (or bad implementation), so it looks like hw vs lapic
problem.

Jarek P.
