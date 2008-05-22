From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/4] modules: proper cleanup of kobject without CONFIG_SYSFS
Date: Thu, 22 May 2008 19:20:22 +1000
Message-ID: <200805221920.22920.rusty@rustcorp.com.au>
References: <1211277589-8565-1-git-send-email-den@openvz.org> <1211277589-8565-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935697AbYEVJ1p@vger.kernel.org>
In-Reply-To: <1211277589-8565-3-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 May 2008 19:59:48 Denis V. Lunev wrote:
> kobject: '<NULL>' (ffffffffa0104050): is not initialized, yet kobject_put()

Thanks Denis.

This patch masks a deeper problem; looks like you can't load any modules with 
CONFIG_SYSFS=n:

kernel/module.c:
int mod_sysfs_init(struct module *mod)
{
	int err;
	struct kobject *kobj;

	if (!module_sysfs_initialized) {
		printk(KERN_ERR "%s: module sysfs not initialized\n",
		       mod->name);
		err = -EINVAL;
		goto out;
	}

AFAICT, module_sysfs_initialized is not ever set if !CONFIG_SYSFS.

I can't see the point of module_sysfs_initialized.  It was introduced by Greg 
in commit 823bccfc ("remove "struct subsystem" as it is no longer needed").

Greg, what were you trying to do here?  Modules can't be loaded before 
param_sysfs_init(): are you trying to handle the case where the 
kset_create_and_add() fails?

Thanks,
Rusty.
