From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Wed, 5 Sep 2012 13:08:35 -0400
Message-ID: <20120905170835.GA2041@redhat.com>
References: <20120905043523.GA12988@redhat.com>
 <CAF1ivSauxzNhrm9c==_xFpuh9Lo3KrUNLNRb_62fLZxMfTuU1w@mail.gmail.com>
 <CAK6E8=dWnd1LYJEnvmiG+CN7x7jBt5OL5uv=4L=2Cx3=NmW3tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lin Ming <mlin@ss.pku.edu.cn>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056Ab2IERIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 13:08:42 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=dWnd1LYJEnvmiG+CN7x7jBt5OL5uv=4L=2Cx3=NmW3tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 09:37:12AM -0700, Yuchung Cheng wrote:
 > On Wed, Sep 5, 2012 at 9:04 AM, Lin Ming <mlin@ss.pku.edu.cn> wrote:
 > > On Wed, Sep 5, 2012 at 12:35 PM, Dave Jones <davej@redhat.com> wrote:
 > >> Just hit this bug on 3.6-rc4.
 > >>
 > >> The BUG is..
 > >>
 > >>         BUG_ON(!timer->function);
 > >
 > > TCP keepalive timer is setup when the socket is created.
 > >
 > > __sock_create
 > > inet_create
 > > tcp_v4_init_sock
 > > tcp_init_sock
 > > tcp_init_xmit_timers
 > > inet_csk_init_xmit_timers
 > >
 > > timer->function should not be NULL when set keepalive option.
 > >
 > > Strange...have bug somewhere.
 > 
 > is this a passively opened socket or actively opened one?

I have no idea. That fuzzer ran for around 10 hours before it triggered
this.  In that time, millions of syscalls were done.

Even though I had logs of every syscall, the volume of data to sift
through to try and map back to the socket that caused this is firmly
in 'needle in haystick' territory.

	Dave
