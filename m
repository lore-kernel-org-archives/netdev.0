From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [v4.12 regression] netns: NULL deref in fib_sync_down_dev()
Date: Fri, 28 Jul 2017 20:36:02 +0300
Message-ID: <20170728173602.GA30482@splinter>
References: <20170728160047.7tzapklj7zrgxktq@qmqm.qmqm.pl>
 <20170728164331.GA5268@splinter>
 <CAM_iQpXmUfdUzsu7Xpc2EjkePQCEjcP+irMkpc4bTDaWfAOVLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46851 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752027AbdG1RgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:36:05 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXmUfdUzsu7Xpc2EjkePQCEjcP+irMkpc4bTDaWfAOVLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 10:28:16AM -0700, Cong Wang wrote:
> On Fri, Jul 28, 2017 at 9:43 AM, Ido Schimmel <idosch@idosch.org> wrote:
> > On Fri, Jul 28, 2017 at 06:00:47PM +0200, Michał Mirosław wrote:
> >> Dear NetDevs,
> >>
> >> Before I go to bisecting, have you seen a following NULL dereference,
> >> yet?  Where should I start looking?  It is triggered by deleting netns
> >> (cut-down script attached - triggers every time).  This was working
> >> correctly under v4.11.x.
> >
> > Thanks for the report. I just reproduced this on my system. I believe
> > the problem is a missing NULL check for 'in_dev' in
> > call_fib_nh_notifiers(). I'll test a fix.
> 
> But your commit 982acb97560c8118c2109504a22b0d78a580547d
> is merged in v4.11-rc1. How could 4.11.x work correctly?

It doesn't. I just reproduced this on v4.11.
