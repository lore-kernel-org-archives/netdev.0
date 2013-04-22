From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Mon, 22 Apr 2013 16:12:46 -0400
Message-ID: <20130422201246.GA20687@hmsreliant.think-freely.org>
References: <20130411191409.GA9790@hmsreliant.think-freely.org>
 <5167A953.1020900@acm.org>
 <20130412113232.GA19966@hmsreliant.think-freely.org>
 <516813A0.1040300@acm.org>
 <20130412184542.GB19966@hmsreliant.think-freely.org>
 <51690AAB.1030102@acm.org>
 <20130415141610.GA3505@hmsreliant.think-freely.org>
 <CAO+b5-oBfH3M0dnrQSs-p1BF_5hKy2tsU-dD=EP9+S=iqPs5ew@mail.gmail.com>
 <20130416172454.GC9241@hmsreliant.think-freely.org>
 <20130418192912.GB29130@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Bart Van Assche <bart.vanassche@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39043 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886Ab3DVUNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:13:00 -0400
Content-Disposition: inline
In-Reply-To: <20130418192912.GB29130@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 03:29:12PM -0400, Neil Horman wrote:
> Well, I guess Ingo doesn't have time  to respond here.  Given that, I've been
> looking at other ways of adressing this problem (as the more I think about it,
> the more I think changing mutex semantics, even to be more accepting, is going
> to be met with lots of friction).  I've come up with the below change, and it
> works well for me (I've hammered it with ifup/downs while sending messages over
> netconsole for 24 hours now without any incident).  I'm not sure I like all the
> details yet (I modified the rx_flag field to be a gneral flags field that uses
> test/set/clear_bit, which I don't think is necessecary, but it seems saner to
> me).  the meat of the change though is that instead of a mutex, we use two flags
> that, respectively, inhibit netpoll usage, and indicate when we're in a netpoll
> service path.  Using these two flags, in conjunction with a wait_queue, we can
> signal to executors in the netpoll path that we're inhibiting its use and expect
> to any user in the path to complete and wake up any contexts in the inhibiting
> path.  Seems to work well for me.  Let me know what you think, and I'll make any
> desired changes and post an official patch.
> 
> Best
> Neil
> 
Bart, any testing/thoughts here?  i'd like to get this fixed in the next few
days, but I'd like to get any feedback you might have first.

Neil
