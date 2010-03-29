From: Ben Hoyt <benhoyt@gmail.com>
Subject: Re: Minimizing TCP latency
Date: Mon, 29 Mar 2010 16:24:04 +1300
Message-ID: <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:57858 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab0C2DYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 23:24:06 -0400
Received: by pva18 with SMTP id 18so2268227pva.19
        for <netdev@vger.kernel.org>; Sun, 28 Mar 2010 20:24:04 -0700 (PDT)
In-Reply-To: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm happy to receive some pointers via this list [...]

Sorry, I should also have posted more about what I've done in terms of
reducing latency so far:

* We've already got TCP_NODELAY activated.

* We've also turned off interrupt coalescing on the network card (for
example, see http://www.29west.com/docs/THPM/latency-interrupt-coalescing.html).

* We've modified our process's CPU affinity so it runs on a core by
itself, reducing interrupt-handling latency slightly further.

* Our code is written in C, and we've tried to keep it as close to the
kernel's socket calls as possible.

So we're currently looking further into ways to reduce latency, which
currently looks like it'll mean digging deeper into the kernel's
networking options and innards.

FYI, we're using RHE release 4 and kernel version 2.6.9 on x86_64 machines.

-Ben
