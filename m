From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: lockdep rt2500usb report
Date: Sun, 27 Aug 2006 09:17:15 +0200
Message-ID: <200608270917.16363.IvDoorn@gmail.com>
References: <44DC4110.6080300@sipsolutions.net> <200608262214.26827.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:64538 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751100AbWH0HRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 03:17:23 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1052683nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 00:17:22 -0700 (PDT)
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200608262214.26827.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 27 August 2006 07:14, Michael Wu wrote:
> On Friday 11 August 2006 01:34, Johannes Berg wrote:
> > This is running wireless-dev from yesterday. All I did was plug in a
> > rt2500usb device into a usb port on a freshly booted system. I have a
> > feeling that this is could be one of the problems reported earlier with
> > the d80211 stack, but I haven't mastered the art of picking through
> > these traces yet... What's swapper doing in there?
> >
> Ok, so it looks like dev_activate (called by dev_open) grabs queue_lock, then 
> calls another function (dev_watchdog_up) which grabs xmit_lock. However, at 
> that point, the device is up enough that someone who wants to try 
> transmitting, can transmit (I think). If they're unlucky enough to transmit 
> after the queue_lock is grabbed but before xmit_lock, we get a deadlock.
>
> This seems avoidable either by setting carrier_off before calling dev_open, 
> and turning it back on at a safe point (on association?), or simply refusing 
> to transmit until it is reasonable to do so. (a similar thing was done in 
> adm8211: call netif_stop_queue and return 1 if we're not ready to tx yet in 
> order to hold skbs until association, where netif_wake_queue would be 
> called.)
 
But in the end this is something that should be fixed in the stack right?
rt2x00 indeed seems to miss the ieee80211_netif_oper() commands,
I'll add them immediately.

Thanks.

Ivo
