From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Fri, 11 Aug 2006 10:55:10 +0400
Message-ID: <20060811065509.GA13413@2ka.mipt.ru>
References: <20060811061535.GA11230@2ka.mipt.ru> <44DC22C1.1060200@redhat.com> <20060811063353.GC11230@2ka.mipt.ru> <20060810.233826.24610567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: drepper@redhat.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161114AbWHKGzl@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060810.233826.24610567.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 10, 2006 at 11:38:26PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 11 Aug 2006 10:33:53 +0400
> 
> > That requires mmap hacks to substitute pages in run-time without user
> > notifications. I do not expect it is a good solution, since on x86 it
> > requires full TLB flush (at least when I did it there were no exported
> > methods to flush separate addresses).
> 
> You just need to provide a do_no_page method, the VM layer will
> take care of the page level flushing or whatever else might be
> needed.

Yes, it is the simplest way to extend mapping but not to replace pages
which are successfully mapped, but such hacks are not needed for kevent
which only expects to extend mapping when number of ready kevents
increases.

So I will create such implementation and will place a reduced amount of
info into that pages.

-- 
	Evgeniy Polyakov
