From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [2.6.25-rc2] System freezes ca. 1 minute after logging into KDE
Date: Sun, 17 Feb 2008 21:22:48 +0100
Message-ID: <939d53060802171222m4619de97u3aa4ed7cb27e6e75@mail.gmail.com>
References: <200802171139.13615.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Frans Pop" <elendil@planet.nl>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:5325 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbYBQUWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 15:22:49 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1052689rvb.1
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2008 12:22:48 -0800 (PST)
In-Reply-To: <200802171139.13615.elendil@planet.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 17, 2008 11:39 AM, Frans Pop <elendil@planet.nl> wrote:
> (resend a third time because previous attempts never reached the lists
> due to a bug in my MUA; my apologies to David for spamming his inbox)
>
> Linus Torvalds wrote:
> > But hey, you can try to prove me wrong.  I dare you.
> Me too, me too!
>
> Weird issue this.
> About a minute after logging into KDE the system freezes, but only
> partially. The keyboard is completely dead in all cases (no console
> switching, no SysRq), but some tasks stay running. One time music continued
> playing, other times it stopped. One time the desktop clock continued
> ticking, other times it stopped. One time I could close a window using the
> mouse, but other windows were frozen.
> It's not just KDE that's frozen; one time I switched to VT1 before the
> freeze happened, but that became unusable too.
> Zilch in the logs.
>
> I've bisected it down to:
> commit 69cc64d8d92bf852f933e90c888dfff083bd4fc9
> Author: David S. Miller <davem@davemloft.net>
>     [NDISC]: Fix race in generic address resolution
>
> Confirmed that this is really the culprit by reverting this commit on top
> of -rc2, which is now running fine.
>
> I'm using IPv6 (local network only) together with IPv4, use a bridge (br0)
> and have an NFS4 mount active.

I've encountered the same issue last Thursday. Here, I can hang my machine
with ping6. I've also bisected it down to the same commit.

I've sent some kernel traces which shows how the soft lock up occurs. See
thread: "[PATCH][RFC] race in generic address resolution"
http://www.spinics.net/lists/netdev/msg55375.html

Benjamin


>
> Cheers,
> FJP
>
>
