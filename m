From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Same data to several sockets with just one syscall ?
Date: Fri, 12 Feb 2016 02:35:56 -0800
Message-ID: <1455273356.31770.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGWmfYrGv8NdJQHs6OA=b=ao8=25JUoZAK_i65+GMFX1OyV-fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Scordino <claudio@evidence.eu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37371 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbcBLKf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 05:35:58 -0500
Received: by mail-wm0-f48.google.com with SMTP id g62so13622216wme.0
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 02:35:58 -0800 (PST)
In-Reply-To: <CAGWmfYrGv8NdJQHs6OA=b=ao8=25JUoZAK_i65+GMFX1OyV-fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-02-12 at 09:53 +0100, Claudio Scordino wrote:

> This makes the application waste time in entering/exiting the kernel
> level several times.

syscall overhead is usually small. Real cost is actually getting to the
socket objects (fd manipulation), that you wont avoid with a
super-syscall anyway.

> Moreover, if I'm not wrong, the kernel is free to execute pending work
> (e.g., softirqs) when returning from a syscall, making the application
> experience further latency.

Well, sofirqs can happen even in the middle of syscalls, not only at the
end of them.
