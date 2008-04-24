From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 18:06:55 +0200
Message-ID: <517f3f820804240906k6a701c2et86a4cabd730a8651@mail.gmail.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	 <20080424112514.055d8071@the-village.bc.nu>
	 <481096C3.2020206@redhat.com>
	 <20080424152436.6cf53c1b@the-village.bc.nu>
	 <4810A46B.1090809@redhat.com>
	 <20080424160352.30f2dd5b@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ulrich Drepper" <drepper@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:35754 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760137AbYDXQG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:06:59 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3138408fgb.17
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 09:06:56 -0700 (PDT)
In-Reply-To: <20080424160352.30f2dd5b@the-village.bc.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/08, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > You didn't read what I wrote.
>
>
> The feeling is mutual
>
>
>  > For those the implementer must ensure that during the development no
>  > value is used which can conflict with any current and future assigned
>  > value and not with any other development.
>
>
> Kernel socket type values are assigned by the kernel team so that
>  isn't a problem.
>
>
>  > > Every other property of a socket via accept() is inherited from the
>  > > parent. Making one property different would be bizarre and ugly.
>  >
>  > Implementing this would visibly change existing code and it would
>  > actively violate POSIX.  Not a good idea.
>
>
> POSIX has no interface for this new behaviour you propose so that is
>  complete crap. The moment you use one of these features you stepped
>  outside of the POSIX spec - and you know that. If there was an existing
>  standard we wouldn't have a problem.

Alan, I agree with your analysis of the standard on that last para,
but I'm still not convinced that having the behavior inherited from
accept() would be good.  The problem (IIUC) is that after the
accept(), a userland programmer might want to immediately change the
O_CLOEXEC for the descriptor, and there would be the same race there
that this whole thread is about avoiding.

-- 
I'll likely only see replies if they are CCed to mtk.manpages at gmail dot com
