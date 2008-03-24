From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [RFC PATCH] kernel: add byteorder macros with alignment fixups
Date: Mon, 24 Mar 2008 09:35:43 -0700
Message-ID: <1206376543.9265.5.camel@brick>
References: <1206034454.17059.4.camel@brick>
	 <20080320182911.GQ10722@ZenIV.linux.org.uk>
	 <1206038244.17059.7.camel@brick>
	 <20080320190953.GR10722@ZenIV.linux.org.uk>
	 <1206040953.17059.13.camel@brick>  <20080323135939.GC4580@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:61831 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbYCXQfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 12:35:46 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1507433rvb.1
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 09:35:45 -0700 (PDT)
In-Reply-To: <20080323135939.GC4580@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-03-23 at 14:59 +0100, Pavel Machek wrote:
> On Thu 2008-03-20 12:22:33, Harvey Harrison wrote:
> > +#ifdef __KERNEL__
> > +
> > +static inline u64 le64_to_cpu_unaligned(void *p)
> > +{
> > +	return __le64_to_cpu(get_unaligned((__le64 *)p));
> > +}
> 
> Why the cast? Should le64_to_cpu() take __le64 * parameter, so that normal
> typechecking still works?
> 							Pavel

Well, most places that would use this have a char *, or a u8 * so I was
avoiding a cast in most callers.

HPA made a good suggestion about this being in asm-generic allowing
arches to optimize this, so I'm reworking with that approach.

Harvey

