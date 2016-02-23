From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Variable download speed
Date: Tue, 23 Feb 2016 08:28:16 -0500
Message-ID: <CADVnQyngzgLhbo6of1vTq5MH4mk4rSR6_KLWCCXkndK6QYynAw@mail.gmail.com>
References: <alpine.LNX.2.20.1602231216240.29937@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: sdrb@onet.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36057 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbcBWN2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:28:17 -0500
Received: by mail-ob0-f173.google.com with SMTP id gc3so193698755obb.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 05:28:16 -0800 (PST)
In-Reply-To: <alpine.LNX.2.20.1602231216240.29937@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 6:19 AM, <sdrb@onet.eu> wrote:
> My question is: what causes such dynamic change in
> the window size (while transferring data)?
> Is it some kernel parameter wrong set or something like this?

That sounds like TCP receive buffer auto-tuning (also called "Dynamic
right-sizing (DRS)" (Fisk and Feng, 2001):

  http://permalink.lanl.gov/object/tr?what=info:lanl-repo/lareport/LA-UR-01-5460

The Linux TCP receiver will, by default, dynamically adjust the
receive window to a value that supports the rate at which the
application successfully reads data out of the socket.

> Do I have any influence on such dynamic change in tcp window size?

You might check on the receiver host with top/mpstat/strace/etc to see
whether the receiving application is limiting performance in some way.
This kind of behavior can show up if the receiver is sometimes
CPU-saturated, or limited by the throughput of the medium on to which
it is writing the data.

If you control the receiver software, you can use
setsockopt(SO_RCVBUF) to explicitly set the receive buffer size, and
see if that helps. If it doesn't, that would suggest that it is indeed
the receiving application that is limiting performance.

If you could provide a tcpdump trace (headers only, e.g.,  -s 96)
taken on the sender, we could check to see if we can see any problems
in the TCP sender or receiver behavior.

cheers,
neal
