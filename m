From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 rx length errors
Date: Sun, 20 Sep 2009 18:46:06 -0700
Message-ID: <20090920184606.5a75aba6@nehalam>
References: <c5bd819b0909180641n7c353b80tc15b9c9fe02d5c95@mail.gmail.com>
	<20090919233536.f5fb700c.akpm@linux-foundation.org>
	<20090920110527.39fd7af5@s6510>
	<392fb48f0909201511h34c71e0au838b52c413d517e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Grozdan <neutrino8@gmail.com>, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753838AbZIUBqK@vger.kernel.org>
In-Reply-To: <392fb48f0909201511h34c71e0au838b52c413d517e0@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Sep 2009 07:11:21 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> 2009/9/21 Stephen Hemminger <shemminger@vyatta.com>
> 
> > On Sat, 19 Sep 2009 23:35:36 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > > (added cc's from the MAINTAINERS file)
> > >
> > > On Fri, 18 Sep 2009 15:41:45 +0200 Grozdan <neutrino8@gmail.com> wrote:
> >
> 
> <snip>
> 
> > > martian destination 0.0.0.0 from 172.23.204.1, dev eth0
> > > > sky2 eth0: rx length error: status 0x4420100 length 598
> > > > sky2 eth0: rx length error: status 0x5ea0100 length 598
> >
> > This error status occurs if the length reported by the PHY does not
> > match the len reported by the DMA engine.  The error status is:
> >   0x4420100 = length 1090 + broadcast packet...
> >
> > No idea what is on your network, but perhaps there is some MTU confusion?
> > Since martian destination seems related, knowing more about that packet
> > might help.
> >
> >
> This appears to be the same problem reported at:
> 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/292445
> 
> Mike

This really looks like multiple packets are getting smashed
together into one DMA, i.e a hardware timing related issue.
it might be possible to work around the problem
by separating them.

-- 
