From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [v4.12 regression] netns: NULL deref in fib_sync_down_dev()
Date: Fri, 28 Jul 2017 19:43:31 +0300
Message-ID: <20170728164331.GA5268@splinter>
References: <20170728160047.7tzapklj7zrgxktq@qmqm.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41637 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752459AbdG1Qnh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 12:43:37 -0400
Content-Disposition: inline
In-Reply-To: <20170728160047.7tzapklj7zrgxktq@qmqm.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 06:00:47PM +0200, Michał Mirosław wrote:
> Dear NetDevs,
> 
> Before I go to bisecting, have you seen a following NULL dereference,
> yet?  Where should I start looking?  It is triggered by deleting netns
> (cut-down script attached - triggers every time).  This was working
> correctly under v4.11.x.

Thanks for the report. I just reproduced this on my system. I believe
the problem is a missing NULL check for 'in_dev' in
call_fib_nh_notifiers(). I'll test a fix.
