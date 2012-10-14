From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Mon, 15 Oct 2012 00:01:31 +0200
Message-ID: <1350252091.21172.17257.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350248858.21172.17197.camel@edumazet-glaptop>
	 <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	 <1350250542.21172.17229.camel@edumazet-glaptop>
	 <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42659 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab2JNWBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 18:01:37 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so2689406eek.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 15:01:35 -0700 (PDT)
In-Reply-To: <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 23:54 +0200, Jan Hinnerk Stosch wrote:
> 2012/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> > So ntpd claims to "Listen normally on 4 lo ::1 UDP 123" but lsof doesnt
> > display a socket bound to ::1 port 123
> >
> > So I would say there is a ntpd bug.
> >
> > You could try to strace ntpd from the very beginning of its life, so
> > that we check what it does exactly.
> >
> > service ntp stop
> > strace -o /tmp/STRACE /usr/bin/ntpd -g -u ntp:ntp
> >
> >
> >
> 
> Ok, here is the strace output. I wonder whether this is enough as it
> exits very early - ntp still running though.

Please add -f to follow children

strace -o /tmp/STRACE -f /usr/bin/ntpd -g -u ntp:ntp
