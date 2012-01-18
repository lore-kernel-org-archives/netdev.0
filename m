From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] add netconsole support for xen-netfront
Date: Wed, 18 Jan 2012 08:59:36 +0000
Message-ID: <1326877176.29475.37.camel@dagon.hellion.org.uk>
References: <1326271956-25565-1-git-send-email-zhenzhong.duan@oracle.com>
	 <20120112141745.GA7685@phenom.dumpdata.com>
	 <1326452769.17210.331.camel@zakaz.uk.xensource.com>
	 <4F15EB3E.3060700@oracle.com> <20120117215100.GA25367@phenom.dumpdata.com>
	 <4F160113.1030503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Zhenzhong Duan <zhenzhong.duan@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gurudas.pai@oracle.com" <gurudas.pai@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>
To: Tina Yang <tina.yang@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F160113.1030503@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-17 at 23:15 +0000, Tina Yang wrote:
> On 1/17/2012 1:51 PM, Konrad Rzeszutek Wilk wrote:
> > On Tue, Jan 17, 2012 at 01:42:22PM -0800, Tina Yang wrote:
> >> On 1/13/2012 3:06 AM, Ian Campbell wrote:
> >> Although netdump is now obsolete, I think it's always a good practice
> >> to preserve caller's irq status as we had a very bad experience
> >> chasing a similar problem caused by such a irq change in RDS
> > Did you find the culprit of it? Was there a patch for that in the
> > upstream kernel?
> Yes.  It has nothing to do with net drivers but same cause
> elsewhere in the kernel.

I didn't think start_xmit could be called with interrupts disabled or
from interrupt context but perhaps I am wrong about that or perhaps
netconsole changes things?

Right, Documentation/networking/netdevices.txt states that start_xmit
can be called with interrupts disabled by netconsole and therefore using
the irqsave/restore locking in this function is, AFAICT, correct.

> >> in the not too long ago past.
> > OK, it sounds like it was issues in the past but might not be the
> > case anymore.
> >
> > Could please re-test it without that spinlock irqsave patch using
> > the upstream kernel (or just UEK2 since it is an 3.0 type kernel).
> Shouldn't be the case now, but don't know about the future.
> The fact is as long as there is a new caller that has the expectation
> of preserved irq status, it would be a problem.

The question is not so much what may or may not be a problem in the
future but what the requirements of this function are, in particular
those imposed by the network stack for the start_xmit function.

> As Ian said, some net drivers have been cautious in this regard already by
> saving/restoring the status, but apparently not everyone.

I was talking about the interrupt/poll handler here since I hadn't yet
noticed that the locking change was also in start_xmit and not just the
poll/interrupt paths (which was actually just code motion and not a
locking change in any case).

Ian.
