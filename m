From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 3/4] modules: proper cleanup of kobject without
	CONFIG_SYSFS
Date: Thu, 22 May 2008 15:44:21 +0400
Message-ID: <1211456661.7496.6.camel@iris.sw.ru>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
	 <1211277589-8565-3-git-send-email-den@openvz.org>
	 <200805221920.22920.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32876 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756838AbYEVLog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 07:44:36 -0400
In-Reply-To: <200805221920.22920.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-05-22 at 19:20 +1000, Rusty Russell wrote:
> On Tuesday 20 May 2008 19:59:48 Denis V. Lunev wrote:
> > kobject: '<NULL>' (ffffffffa0104050): is not initialized, yet kobject_put()
> 
> Thanks Denis.
> 
> This patch masks a deeper problem; looks like you can't load any modules with 
> CONFIG_SYSFS=n:
> 
> kernel/module.c:
> int mod_sysfs_init(struct module *mod)
> {
> 	int err;
> 	struct kobject *kobj;
> 
> 	if (!module_sysfs_initialized) {
> 		printk(KERN_ERR "%s: module sysfs not initialized\n",
> 		       mod->name);
> 		err = -EINVAL;
> 		goto out;
> 	}
> 
> AFAICT, module_sysfs_initialized is not ever set if !CONFIG_SYSFS.
> 
> I can't see the point of module_sysfs_initialized.  It was introduced by Greg 
> in commit 823bccfc ("remove "struct subsystem" as it is no longer needed").
> 
> Greg, what were you trying to do here?  Modules can't be loaded before 
> param_sysfs_init(): are you trying to handle the case where the 
> kset_create_and_add() fails?

Basically you miss
static inline int mod_sysfs_init(struct module *mod)
{
        return 0;
}
in include/linux/module.h

So, without CONFIG_SYSFS a dummy stab for mod_sysfs_init is called.

Regards,
	Den

