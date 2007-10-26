From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [linux-pm] QUESTION: How to fix race between .suspend routine and watchdog timer
Date: Fri, 26 Oct 2007 13:48:42 +0200
Message-ID: <200710261348.42748.maximlevitsky@gmail.com>
References: <Pine.LNX.4.44L0.0710251259230.7029-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:11278 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbXJZLth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:49:37 -0400
Received: by ug-out-1314.google.com with SMTP id z38so658218ugc
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 04:49:35 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.44L0.0710251259230.7029-100000@netrider.rowland.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 25 October 2007 19:02:12 Alan Stern wrote:
> On Thu, 25 Oct 2007, Maxim Levitsky wrote:
> 
> > Hi,
> > 
> > Recently, trying to fix saa7134 suspend/resume problems I found that there 
> > is a race between IRQ handler and .suspend , and that I cant let driver access the device
> > while its in D3 since it can lock up some systems.
> > 
> > Now I am looking to fix those issues in two drivers that have my .suspend/.resume routines.
> > the saa7134 capture chip and dmfe, the davicom network driver.
> > 
> > Looking through the dmfe code, I noticed yet another possible race.
> > A race between the .suspend, and a timer that serves both as a watchdog, and link state detector.
> > Again I need to prevent it from running during the suspend/resume, but how?
> > 
> > I can use del_timer in .suspend, and mod_timer in .resume, but that doesn't protect against
> > race with already running timer.
> > I can use del_timer_sync, but it states that it is useless if timer re-enables itself, and I agree with that.
> > In dmfe case the timer does re-enable itself.
> 
> That comment isn't right.  del_timer_sync works perfectly well even if
> the timer routine re-enables itself, provided it stops doing so after a
> small number of iterations.
Thanks for the info. but....
Due to the "don't access the hardware, while powered-off" rule, I must know that the timer isn't running.
and won't be.
So what function to use (if possible) to be sure that the timer won't run anymore?
(Taking in the account the fact that it re-enables itself)
> 
> > I can put checks in the timer for ->insuspend, and don't re enable it if set,
> > but that opens a new can of worms with memory barriers, etc...
> 
> You don't have to worry about any of that stuff.  Just check the 
> insuspend flag and don't re-enable the timer if it is set.  Even 
> without any memory barriers, the timer routine won't iterate more than 
> once or twice.
> 
> Alan Stern
> 
> 

Thanks,
	Best regards,
	`	Maxim Levitsky
