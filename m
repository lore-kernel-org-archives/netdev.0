From: Jesse Barnes <jbarnes@sgi.com>
Subject: Re: [PATCH] use mmiowb in tg3.c
Date: Thu, 21 Oct 2004 22:01:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410212201.35430.jbarnes@sgi.com>
References: <200410211613.19601.jbarnes@engr.sgi.com> <200410211628.06906.jbarnes@engr.sgi.com> <20041021164007.4933b10b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, akpm@osdl.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com,
        gnb@sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041021164007.4933b10b.davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday, October 21, 2004 6:40 pm, David S. Miller wrote:
> On Thu, 21 Oct 2004 16:28:06 -0700
>
> Jesse Barnes <jbarnes@engr.sgi.com> wrote:
> > This patch originally from Greg Banks.  Some parts of the tg3 driver
> > depend on PIO writes arriving in order.  This patch ensures that in two
> > key places using the new mmiowb macro.  This not only prevents bugs (the
> > queues can be corrupted), but is much faster than ensuring ordering using
> > PIO reads (which involve a few round trips to the target bus on some
> > platforms).
>
> Do other PCI systems which post PIO writes also potentially reorder
> them just like this SGI system does?  Just trying to get this situation
> straight in my head.

The HP guys claim that theirs don't, but PPC does, afaik.  And clearly any 
large system that posts PCI writes has the *potential* of reordering them.

Thanks,
Jesse
