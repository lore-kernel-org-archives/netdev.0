From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: Issue with GRE tunnel, created with "local any" on kernel 3.14
Date: Thu, 31 Jul 2014 12:47:37 +0400
Message-ID: <20140731124737.442be6f4c55fec059028eae2@qrator.net>
References: <53C91AA3.1020106@gentoo.org>
	<20140718223204.9422aa8df81f7ac5187588bb@qrator.net>
	<53D9E22C.6030804@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergey Popov <pinkbyte@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:43941 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247AbaGaIro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 04:47:44 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so1799322lab.35
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 01:47:40 -0700 (PDT)
In-Reply-To: <53D9E22C.6030804@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jul 2014 10:29:00 +0400
Sergey Popov <pinkbyte@gentoo.org> wrote:

> > I have no patch to fix this issue, but as a workaround, you can use 
> > ip tunnel change tun_test tos inherit.
> 
> Thanks, your workaround works as expected if tos value defined
> explicitly. Though, I do not understand why: iproute2 documentation says
> that default tos value in 'ip tunnel' command is already 'inherit'.

man ip-tunnel says default tos is 00, and that's true. If you're about *.tex
files under iproute2.git/doc, they are more than 10 years old, I doubt if they
are maintained. Otherwise I don't know where you found it.

This workaround works because setting tos=inherit disables tunnel route cache,
which is buggy in your release (it doesn't cache source address).

Btw, thanks for the report, David has accepted the patch today, commit
95cb574 (ip_tunnel(ipv4): fix tunnels with "local any remote $remote_ip"), so
I think next kernel releases will have it.
