From: Luke Hutchison <luke.hutch@gmail.com>
Subject: Re: Networking hangs when too many parallel requests are made at once
Date: Tue, 9 Nov 2010 14:04:03 -0500
Message-ID: <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:52768 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871Ab0KITEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 14:04:44 -0500
Received: by ywc21 with SMTP id 21so4564812ywc.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 11:04:44 -0800 (PST)
In-Reply-To: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 9, 2010 at 1:30 PM, Luke Hutchison <luke.hutch@gmail.com> wrote:
> Since around Linux kernel 2.6.33 or so (but maybe as early as
> 2.6.31, not sure exactly what version), when restoring a crashed or
> closed browser session of either Firefox or Chrome where lots of tabs
> (say 10-40) open simultaneously, the networking stack is brought to
> its knees -- most or all the tabs eventually time out without data, or
> a few tabs might get some data and then display a partial web page.

I forgot to mention, I have glibc-2.12.90-18.x86_64.

Also the following screenshot may be useful

http://web.mit.edu/~luke_h/www/dns-hang-problem.png

Basically in the usage depicted by the screenshot, I had Chrome open
with probably 30-50 tabs across several windows, I then started an scp
transfer of a large file and waited for it to stabilize, then closed
the browser and re-opened it, restoring the tabs.  Within a second or
two (after the first few lucky browser tabs got some content), DNS
hung, and pinging a domain name from the commandline no longer worked
(ruling out a bug in the browser itself).  However the scp transfer
continued at the same rate, and pinging an IP address directly
continued to work fine (in this case; at other times network
connections to already-resolved IP addresses can seem flaky I think,
but I haven't been able to reproduce these problems as easily as with
DNS, which has 100% reproducibility).  You can see that CPU usage
dropped from 100% to something like 50% when the browser tabs all
started blocking (but actually I'm surprised that CPU usage didn't
drop to zero).  In this instance, as soon as I shut down the browser,
pinging a domain name worked immediately again (although, as I
mentioned previously, sometimes it can take a minute or more after
killing the browser for name resolution to jump back into working
mode).  "ifdown eth0 ; ifup eth0" *usually* fixes the problem by
canceling all pending requests.

>From one of the RH engineers:

> It's not a driver issue, since it occurs
> with two different devices... it's not a configuration issue since it
> occurs on a LiveCD... For the same reason it's unlikely to be a
> userspace issue... It's unlikely to be a local network issue since you
> say it happens in multiple locations...
>
> Absolutely bizarre. :/

Any help greatly appreciated.

Thanks,
Luke
