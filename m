From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 18:45:43 +0200
Message-ID: <517f3f820804240945l2dc203afx8fa432ac41219236@mail.gmail.com>
References: <20080424160352.30f2dd5b@the-village.bc.nu>
	 <20080424154441.GG2255@devserv.devel.redhat.com>
	 <20080424162444.1c5b9ba2@the-village.bc.nu>
	 <20080424.090008.232544945.davem@davemloft.net>
	 <20080424163835.55520b5b@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, jakub@redhat.com,
	drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:33111 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbYDXQps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:45:48 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3162514fgb.17
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 09:45:43 -0700 (PDT)
In-Reply-To: <20080424163835.55520b5b@the-village.bc.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/08, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> On Thu, 24 Apr 2008 09:00:08 -0700 (PDT)
>
> David Miller <davem@davemloft.net> wrote:
>
>
> > From: Alan Cox <alan@lxorguk.ukuu.org.uk>
>  > Date: Thu, 24 Apr 2008 16:24:44 +0100
>  >
>  > > BTW in 4.4BSD and derivatives if I remember rightly F_CLOEXEC *is*
>  > > inherited across accept() so I doubt any user space software will be too
>  > > upset by such a shift.
>  >
>  > It actually doesn't.
>  >
>  > Just like in Linux, no file descriptor flags are inherited.
>
>
> NDELAY certainly appears to be looking at Stevens.

A while back I did some testing of this point.  These were the results I noted:

FreeBSD 4.8
O_NONBLOCK and O_ASYNC are inherited
FD_CLOEXEC is not inherited

Solaris 8
O_NONBLOCK and O_ASYNC are inherited
FD_CLOEXEC is not inherited

Tru64 5.1 (sep 03, testdrive)
No F_SETFL flags are inherited
FD_CLOEXEC is not inherited

HP-UX 11
No F_SETFL flags are inherited
FD_CLOEXEC is not inherited
