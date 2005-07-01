From: "David S. Miller" <davem@davemloft.net>
Subject: Re: -mm -> 2.6.13 merge status (dropped patches?)
Date: Thu, 30 Jun 2005 19:52:54 -0700 (PDT)
Message-ID: <20050630.195254.71110580.davem@davemloft.net>
References: <200506301605_MC3-1-A320-D9D6@compuserve.com>
	<20050630161456.2ef0ab32.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 76306.1226@compuserve.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263203AbVGACxh@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <20050630161456.2ef0ab32.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Thu, 30 Jun 2005 16:14:56 -0700

> Chuck Ebbert <76306.1226@compuserve.com> wrote:
> >
> > What happened to:
> > 
> >         remove-last_rx-update-from-loopback-device.patch
> 
> Davem rejected it.  hm, I can't find the email trail - it was cc'ed to
> netdev@oss.sgi.com mid-March, but nothing seems to have been sent back.

Every network device must reliably set ->last_rx, there are parts
of the kernel which depend upon this attribute having an accurate
value.

The bonding driver is one example.  And whilst one can argue that
loopback is unlikely to be used as part of a bond, it's massively
better from a consistency perspective if this invariant can be
relied upon across all networking drivers.

In short, the NUMA scalability hacks to loopback have gotten out
of control, and we need to stop this madness somewhere.
