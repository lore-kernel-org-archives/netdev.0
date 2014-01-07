From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [Patch net] cls_cgroup: fix memory leak in cls_cgroup_change()
Date: Tue, 7 Jan 2014 21:19:35 +0000
Message-ID: <20140107211935.GA31788@casper.infradead.org>
References: <1388776399-27657-1-git-send-email-xiyou.wangcong@gmail.com>
 <20140103.210209.901517258686201934.davem@davemloft.net>
 <CAM_iQpU8rvceS7tAgv6DacHvaxJFBFDJSFhhBhWV-wqJ+A_xOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58270 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbaAGVTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:19:38 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpU8rvceS7tAgv6DacHvaxJFBFDJSFhhBhWV-wqJ+A_xOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/14 at 03:23pm, Cong Wang wrote:
> On Fri, Jan 3, 2014 at 6:02 PM, David Miller <davem@davemloft.net> wrote:
> > From: Cong Wang <xiyou.wangcong@gmail.com>
> > Date: Fri,  3 Jan 2014 11:13:19 -0800
> >
> >> Fix it by moving allocation to ->init().
> >>
> >> Cc: Thomas Graf <tgraf@suug.ch>
> >> Cc: David S. Miller <davem@davemloft.net>
> >> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> >> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> >
> > I don't understand how the memory leak can happen, please explain
> > it in your commit message.
> >
> 
> The leak happens when ->change() fails after the allocation
> inside  cls_cgroup_change(), its caller only does cleanup
> when itself creates one. So, the callee should do cleanup
> on error path by itself. But I may miss something.
> 
> Since it is not urgent at all, I will explain this in changelog
> and resend it for net-next.

I have no problem with the intent of the change but I want to
note that the behavior was introduced intentionally to be in
line with behaviour of other classifiers that use chaining.

It's not a leak, the reference is kept and freed when the
chain itself is deleted.
