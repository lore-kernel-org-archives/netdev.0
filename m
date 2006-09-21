From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Thu, 21 Sep 2006 12:14:06 +0200
Message-ID: <20060921101406.GK18349@postel.suug.ch>
References: <20060919.000800.127570535.yoshfuji@linux-ipv6.org> <20060918185746.GD18349@postel.suug.ch> <20060921.143046.29082693.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:63181 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750705AbWIUKNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 06:13:46 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060921.143046.29082693.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-09-21 14:30
> In article <20060918185746.GD18349@postel.suug.ch> (at Mon, 18 Sep 2006 20:57:46 +0200), Thomas Graf <tgraf@suug.ch> says:
> > Same here, it doesn't make sense to export macros only of functional
> > value and used by userspace only. The same issue will pop up once
> > all users have been converted to use the new netlink interface.
> > Keeping the old interface around just so userspace doesn't have to
> > make copies doesn't make sense. I think it's better to start fixing
> > userspace than to try and keep headers source compatible.
> 
> Backward compatibility is one of the most important factor.
> A careless breakage is, say,  of "brain freeze."

This isn't about backward compatibility, it's about userspace
applications not sticking to the policy of using kernel headers.
Which applications will break? I'll fix them. The kernel is
only required to provide binary backward compatibility.

> About these macros, we have other similar *_{RTA,PAYLOAD}()s in kernel,
> which are not used by kernel but are exported to userspace.  They are
> forming part of our API, and they're good example how to use netlink
> interface.

Actually they are miserable examples of how to use netlink, they
only cover part of the interface required and lead to tons of
duplicated code in every userspace application. F.e. the different
semantics of simliar interfaces inside the kernel and libnetlink
have lead to countless bugs.

> Yes, we could change the interface, but we definately need to give
> them graceful period at least; we can do it in 2.7, or at least,
> after 2-3 stable releases.

Even thinking of 2.7 is not an option for me and I don't get the
point in waiting 6 months before fixing userspace applications.
