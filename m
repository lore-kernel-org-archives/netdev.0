From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/4] modules: proper cleanup of kobject without CONFIG_SYSFS
Date: Fri, 23 May 2008 11:51:39 +1000
Message-ID: <200805231151.40161.rusty@rustcorp.com.au>
References: <1211277589-8565-1-git-send-email-den@openvz.org> <200805221920.22920.rusty@rustcorp.com.au> <1211456661.7496.6.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37212 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754314AbYEWBvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 21:51:50 -0400
In-Reply-To: <1211456661.7496.6.camel@iris.sw.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 May 2008 21:44:21 Denis V. Lunev wrote:
> On Thu, 2008-05-22 at 19:20 +1000, Rusty Russell wrote:
> > On Tuesday 20 May 2008 19:59:48 Denis V. Lunev wrote:
> > > kobject: '<NULL>' (ffffffffa0104050): is not initialized, yet
> > > kobject_put()
> >
> > AFAICT, module_sysfs_initialized is not ever set if !CONFIG_SYSFS.
> >
>
> Basically you miss
> static inline int mod_sysfs_init(struct module *mod)
> {
>         return 0;
> }
> in include/linux/module.h
>
> So, without CONFIG_SYSFS a dummy stab for mod_sysfs_init is called.

Ah, thanks for the explanation.

Basically, this code is a dog's breakfast.  There's no reason for this to be 
in the header, and no reason for the other mod_sysfs_init() not to be static.  
Ditto for most of the rest.

Patch applied, thanks!
Rusty.
