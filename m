From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 5 May 2008 19:13:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805051910050.20837@alien.or.mcafeemobile.com>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>
 <20080505185850.789d870a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ulrich Drepper <drepper@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:51540 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601AbYEFCNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 22:13:16 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28AECB> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 22:13:15 -0400
In-Reply-To: <20080505185850.789d870a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 May 2008, Andrew Morton wrote:

> On Sun, 4 May 2008 23:42:46 -0400 Ulrich Drepper <drepper@redhat.com> wrote:
> 
> > +static const struct flags_rmap sock_file_flags_remap[] = {
> > +	{ SOCK_CLOEXEC, O_CLOEXEC },
> > +};
> > +
> >  asmlinkage long sys_socket(int family, int type, int protocol)
> >  {
> >  	int retval;
> >  	struct socket *sock;
> > +	int fflags;
> > +
> > +	type = flags_remap(sock_file_flags_remap,
> > +			   ARRAY_SIZE(sock_file_flags_remap),
> > +			   type, &fflags);
> 
> oh, so that's what it does.
> 
> afaict we only ever remap one or two flags.  Would it not be more efficient
> to do that inline?  Something along the lines of:
> 
> 	type = flag_remap(type, &fflags, SOCK_whatever, O_whatever);
> 	type = flag_remap(type, &fflags, SOCK_whatever2, O_whatever2);
> 
> ?

I think it is better to keep it able to remap more than one flag, with a 
single call, that is table driven.



- Davide


