From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Thu, 16 Nov 2006 15:26:05 -0800
Message-ID: <ae017dc00611161526v6bcbddc2ve2c7e10963d25c3b@mail.gmail.com>
References: <455B63EC.8070704@madrabbit.org> <455BFC47.3020006@madrabbit.org>
	 <455CAB2F.1060709@lwfinger.net> <200611162016.42095.mb@bu3sch.de>
	 <455CBDD7.6000507@madrabbit.org> <455CE8FB.2000803@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:23655 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1424559AbWKPX0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 18:26:10 -0500
Received: by ug-out-1314.google.com with SMTP id m3so590039ugc
        for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 15:26:08 -0800 (PST)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <455CE8FB.2000803@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First off, thanks for all your help.

Second off,

On 11/16/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> Ray Lee wrote:
> >
> > If I could figure out a way to make it repeatable, I'd happily do a blind
> > bisect.
[...]
> > I'm open to suggestions on how to make the problem trigger more than once
> > every two days...
>
> I don't know what might be causing the lock problems. I'm more concerned with the NETDEV WATCHDOG
> timeouts. AFAIK, you are the only one still reporting this error. On my system, I get an occasional
> MAC suspend failure, sometimes followed by an BCM43xx_IRQ_XMIT_ERROR.

Last time I had trouble with 2.6.18-rcX, I wasn't the only one, just
the only one reporting it. Can you tell me why reverting the likely
culprit isn't an option? rc6 is out, and Linus is really pushing to
finalize 2.6.19 here soon.

>  From what I read in your post, the timeouts happen a lot more often than once every two days. Once
> we get those fixed, then we can concentrate on the locking.

It's becoming clear that I wasn't so clear :-). No, it doesn't happen
more than once every two (three, now) days. I'm saying that it's only
happened twice, as once the first timeout message starts, the timeouts
don't stop short of a reboot.

Or, in other words, it happened occasionally under 2.6.19-rc3, but
fixed itself. Under 2.6.19-rc5, it's happened less frequently (maybe),
but once it starts, it goes on solid until I reboot the computer.
Until I reboot, the laptop is fully unusable as things start hanging
on the rtnl_lock (X, apparently).

Please see http://madrabbit.org/~ray/messages.gz for the
/var/log/messages to understand what I mean by that. (Though, that was
captured before I'd rebuilt the module with debugging, unfortunately.
Regardless, it may help clarify what I mean here.)

So all the NETDEV WATCHDOG timeouts other than the first (of each of
the two events) appear to be bogus, or side effects of rtnl_lock being
held after the first time, and not clearing out.

<thinks...> Maybe I've got the culprit backward here. Perhaps
something else in my system is locking on rtnl_lock, and bcm43xx can't
acquire it? Could the NETDEV WATCHDOG timeouts be a side effect of
someone acquiring and not releasing the rtnl_lock()? Is that possible?
(ie, would it cause the effect I'm seeing?)

Ray
