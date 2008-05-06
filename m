From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/18] flag parameters: helper function
Date: Mon, 5 May 2008 19:56:38 -0700
Message-ID: <20080505195638.4c4bdc40.akpm@linux-foundation.org>
References: <200805050342.m453gkY4029814@devserv.devel.redhat.com>
	<20080505185103.b9299541.akpm@linux-foundation.org>
	<481FC4E6.5060206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48470 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530AbYEFC47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 22:56:59 -0400
In-Reply-To: <481FC4E6.5060206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 05 May 2008 19:39:34 -0700 Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Andrew Morton wrote:
> > hm, that looks expensive.  The compiler will need to generate a deref of m
> > and rf multiple times around the loop.  Copying them into locals does
> > improve that a lot.
> 
> There really is no problem.  The value is in L1d when it is reused.
> This is the generated code (%rdi is m):
> 
>    f:   85 17                   test   %edx,(%rdi)
>   11:   74 0b                   je     1e <flags_remap+0x1e>
>   13:   8b 47 04                mov    0x4(%rdi),%eax
>   16:   09 01                   or     %eax,(%rcx)

the deref of %rcx can be avoided.

>   18:   8b 07                   mov    (%rdi),%eax
>   1a:   f7 d0                   not    %eax
>   1c:   21 c2                   and    %eax,%edx
> 
> At address 18 the load will be satisfied from L1d.  If you would want to
> cache the value at address f you'd have to create one more instruction.
> 
> This really is the best code sequence.  The compiler could have chosen
> to move the value into a register because the array is const.  But it
> didn't.
> 
> 
> > Also: sorry, but ugh-at-the-naming.  We don't *gain* anything from having
> > idenitifers called f, of, m, n and rf.  And we lose quite a lot in
> > readability and understandability.  It would be much nicer to invest a
> > little bit more typing-time here, IMO.
> 
> That's Davide's code and I didn't change it because it doesn't really
> matter.  This is a trivial function which doesn't need more than 10
> seconds to be understood.  If you insist I'll rename the variables and
> elements but I consider this just busy work.

Well if the objective is saving work then why write any code at all?
