From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH 1/1] eventfd: implementation of EFD_MASK flag
Date: Fri, 8 Feb 2013 22:21:07 +0000
Message-ID: <20130208222107.GA4762@dcvr.yhbt.net>
References: <1360219292-19754-1-git-send-email-sustrik@250bpm.com>
 <20130207144433.527ef024.akpm@linux-foundation.org>
 <5114F2D8.5020300@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5114F2D8.5020300@250bpm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Sustrik <sustrik@250bpm.com> wrote:
> On 07/02/13 23:44, Andrew Morton wrote:
> >That's a nice changelog but it omitted a critical thing: why do you
> >think the kernel needs this feature?  What's the value and use case for
> >being able to poll these descriptors?
> 
> To address the question, I've written down detailed description of
> the challenges of the network protocol development in user space and
> how the proposed feature addresses the problems.
> 
> It's too long to fit into ChangeLog, but it may be worth reading
> when trying to judge the merit of the patch.
> 
> It can be found here: http://www.250bpm.com/blog:16

Using one eventfd per userspace socket still seems a bit wasteful.

Couldn't you use a single pipe for all sockets and write the efd_mask to
the pipe for each socket?

A read from the pipe would behave like epoll_wait.

You might need to use one-shot semantics; but that's probably
the easiest thing in multithreaded apps anyways.
