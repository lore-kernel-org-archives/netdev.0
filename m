From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Pv-drivers] vmxnet3 driver broken since 3.0?
Date: Wed, 14 Dec 2011 13:13:18 -0800
Message-ID: <20111214131318.410a6a9d@s6510.linuxnetplumber.net>
References: <D3F292ADF945FB49B35E96C94C2061B9150914BA@nsmail.netscout.com>
	<CAAsGZS7QL1vQwoq7k2RX_LWeqgE4x5+00NSrRYbCu8vQoGh1Hg@mail.gmail.com>
	<20111212174244.GA31005@dtor-ws.eng.vmware.com>
	<CAJeBh4unodegb1e-Og+kY9AC-+OiHE3Kq_6N=+TZ679CBoSu1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@vmware.com>,
	chetan loke <loke.chetan@gmail.com>, pv-drivers@vmware.com,
	zbiggy@o2.pl, netdev <netdev@vger.kernel.org>
To: sandr8@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57628 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754552Ab1LNVNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 16:13:21 -0500
In-Reply-To: <CAJeBh4unodegb1e-Og+kY9AC-+OiHE3Kq_6N=+TZ679CBoSu1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lastest 3.2 has this fix which should eliminate the problem.


commit 13c07b0286d340275f2d97adf085cecda37ede37
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Mon Dec 12 22:06:55 2011 -0800

    linux/log2.h: Fix rounddown_pow_of_two(1)
    
    Exactly like roundup_pow_of_two(1), the rounddown version was buggy for
    the case of a compile-time constant '1' argument.  Probably because it
    originated from the same code, sharing history with the roundup version
    from before the bugfix (for that one, see commit 1a06a52ee1b0: "Fix
    roundup_pow_of_two(1)").
    
    However, unlike the roundup version, the fix for rounddown is to just
    remove the broken special case entirely.  It's simply not needed - the
    generic code
    
        1UL << ilog2(n)
    
    does the right thing for the constant '1' argment too.  The only reason
    roundup needed that special case was because rounding up does so by
    subtracting one from the argument (and then adding one to the result)
    causing the obvious problems with "ilog2(0)".
    
    But rounddown doesn't do any of that, since ilog2() naturally truncates
    (ie "rounds down") to the right rounded down value.  And without the
    ilog2(0) case, there's no reason for the special case that had the wrong
    value.
    
    tl;dr: rounddown_pow_of_two(1) should be 1, not 0.
    
    Acked-by: Dmitry Torokhov <dtor@vmware.com>
    Cc: stable@kernel.org
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
