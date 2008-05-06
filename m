From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 5 May 2008 19:17:25 -0700
Message-ID: <20080505191725.89faed88.akpm@linux-foundation.org>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>
	<20080505185850.789d870a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0805051910050.20837@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35969 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626AbYEFCSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 22:18:14 -0400
In-Reply-To: <Pine.LNX.4.64.0805051910050.20837@alien.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 May 2008 19:13:14 -0700 (PDT) Davide Libenzi <davidel@xmailserver.org> wrote:

> On Mon, 5 May 2008, Andrew Morton wrote:
> 
> > On Sun, 4 May 2008 23:42:46 -0400 Ulrich Drepper <drepper@redhat.com> wrote:
> > 
> > > +static const struct flags_rmap sock_file_flags_remap[] = {
> > > +	{ SOCK_CLOEXEC, O_CLOEXEC },
> > > +};
> > > +
> > >  asmlinkage long sys_socket(int family, int type, int protocol)
> > >  {
> > >  	int retval;
> > >  	struct socket *sock;
> > > +	int fflags;
> > > +
> > > +	type = flags_remap(sock_file_flags_remap,
> > > +			   ARRAY_SIZE(sock_file_flags_remap),
> > > +			   type, &fflags);
> > 
> > oh, so that's what it does.
> > 
> > afaict we only ever remap one or two flags.  Would it not be more efficient
> > to do that inline?  Something along the lines of:
> > 
> > 	type = flag_remap(type, &fflags, SOCK_whatever, O_whatever);
> > 	type = flag_remap(type, &fflags, SOCK_whatever2, O_whatever2);
> > 
> > ?
> 
> I think it is better to keep it able to remap more than one flag, with a 
> single call, that is table driven.
> 

The table-driven approach is slower for one and probably two bits and it is
somewhat less readable.  What do we gain in return for this?
