From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: missing icmp redirects
Date: Wed, 11 Jun 2014 00:06:13 +0400
Message-ID: <20140611000613.3fb3c563523b73244d90dc44@qrator.net>
References: <5343FE4D.40805@computer.org>
	<DUB123-W19EE656C7ECB42B9D05319ED6B0@phx.gbl>
	<53974A0F.7080908@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lukas Tribus <luky-37@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Per Jessen <per@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:53184 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586AbaFJUGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 16:06:18 -0400
Received: by mail-la0-f44.google.com with SMTP id hr17so4351871lab.31
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 13:06:16 -0700 (PDT)
In-Reply-To: <53974A0F.7080908@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014 20:10:23 +0200
Per Jessen <per@computer.org> wrote:

> Lukas Tribus wrote:
> >> See complete description here:
> >>
> >> https://bugzilla.kernel.org/show_bug.cgi?id=72561
> >>
> >> Summary - some ICMP redirects seem to be missing.
> >>
> Okay, I have devised a way to reproduce the problem:
> 
> ...

It's probably not a bug, but intended behavior. See ip_rt_send_redirect in 
net/ipv4/route.c. The kernel has a built-in per-source-address limiter for icmp
redirects. 

You can disable it for example with 
echo -1 > /proc/sys/net/ipv4/route/redirect_silence
Though I am not sure if it is ok in wild networks.
