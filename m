From: Neal Cardwell <ncardwell@google.com>
Subject: Re: inet_diag_dump_icsk() change seems bogus...
Date: Sun, 2 Feb 2014 10:43:10 -0500
Message-ID: <CADVnQynq6tfd6Hdg0iqD4Wpm805mVXwFT-VUCsWT6YUxo2=wbQ@mail.gmail.com>
References: <20140202.004538.1011276314292086521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:44381 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbaBBPnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 10:43:12 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so3158575eei.35
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 07:43:10 -0800 (PST)
In-Reply-To: <20140202.004538.1011276314292086521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

That was true in 3.12 and earlier, but AFAICT since Eric's 05dbc7b
("tcp/dccp: remove twchain") in 3.13-rc1, there is no head->twchain,
and instead all the connections (both tcp_sock and timewait flavor)
are on the head->chain, so that we do need to check for timewait
sockets. :-)

neal


On Sun, Feb 2, 2014 at 3:45 AM, David Miller <davem@davemloft.net> wrote:
>
> Upon further review, commit 70315d22d3c7383f9a508d0aab21e2eb35b2303a
> ("inet_diag: fix inet_diag_dump_icsk() to use correct state for
> timewait sockets") doesn't seem valid to me.
>
> Take a close look at get_tcp4_sock() and get_timewait4_sock() which
> you reference in your commit message.
>
> The former always gets it's socket from head->chain and the latter
> always gets it's socket from head->twchain.
>
> Yet in this inet_diag_dump_icsk() change, you're changing the
> head->chain iterator to check for timewait sockets.  That doesn't
> seem possible.
>
> Only head->twchain holds timewait sockets, and this code was handling
> it correctly already.
>
> What gives?
