From: "David S. Miller" <davem@redhat.com>
Subject: Re: window tracking firewall involved, was: Re: preliminary
 conclusions regarding window size issues
Date: Thu, 8 Jul 2004 08:37:08 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040708083708.5f63bc71.davem@redhat.com>
References: <20040707232757.GA14471@outpost.ds9a.nl>
	<20040708014443.GE17266@mail.shareable.org>
	<20040708060326.GA22258@outpost.ds9a.nl>
	<20040708063700.GA23496@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamie@shareable.org, shemminger@osdl.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	ALESSANDRO.SUARDI@ORACLE.COM
Return-path: <linux-net-owner@vger.kernel.org>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040708063700.GA23496@outpost.ds9a.nl>
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004 08:37:00 +0200
bert hubert <ahu@ds9a.nl> wrote:

> On Thu, Jul 08, 2004 at 08:03:26AM +0200, bert hubert wrote:
> 
> [ theory that a window tracking firewall drops packets for which it thinks
>   the intended recipient has no room, as they are larger than the window size
>   it sees, where it neglects to scale that window size ]
> 
> > We could verify this assumption by checking if lowering the MTU to say 700
> > allows wscale=3 to work. 
> 
> This has now been confirmed with the packages.gentoo.org firewall!

It's the netfilter patches added to the gentoo WOLK kernel running
on packages.gentoo.org

Specifically, it's the tcp-window-tracking patch from netfilter's
patch-o-matic.  There's some bug in there wrt. it's window scaling
support.

I bet if the tcp-window-scaling diff is removed from the kernel running
there, the problem will totally go away.

I note that it is using a very old version of the tcp-window-tracking
patch, the current version is 2.2 and probably fixes this bug.  The
gentoo linux-2.4.20-wolk-4.14 kernel is using version 1.7
