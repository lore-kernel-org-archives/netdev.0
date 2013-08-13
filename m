From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v5 1/5] bnx2x: protect different statistics flows
Date: Tue, 13 Aug 2013 10:57:19 -0700
Message-ID: <20130813105719.09222122@nehalam.linuxnetplumber.net>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
	<1376349903-3461-2-git-send-email-dmitry@broadcom.com>
	<20130812171208.7dde2569@nehalam.linuxnetplumber.net>
	<20130812.212402.138911128487906526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62822 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757355Ab3HMR5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 13:57:23 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so3248576pdj.29
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 10:57:23 -0700 (PDT)
In-Reply-To: <20130812.212402.138911128487906526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Aug 2013 21:24:02 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 12 Aug 2013 17:12:08 -0700
> 
> > On Tue, 13 Aug 2013 02:24:59 +0300
> > "Dmitry Kravkov" <dmitry@broadcom.com> wrote:
> > 
> >> +	bool					stats_started;
> >> +	struct semaphore			stats_sema;
> > 
> > Is there a reason to use a counting semaphore? Do you expect it to
> > be held across user process boundary? or want count > 1?
> > 
> > Use of semaphores as a locking primitive is discouraged,
> > instead us a mutex.
> 
> Would you please look at the feedback I gave these guys to the
> previous iteration of these changes?
> 
> They were using custom locking primitives and semaphores gave
> the best approximation to the semantics they were looking for.

Your right in this case sempahore makes sense because it is
used to hold off process while hardware responds.
