From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC v2] netfilter: xt_condition: add condition target
Date: Tue, 20 Jul 2010 12:45:28 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007201235250.20447@obet.zrqbmnf.qr>
References: <1279619434-11849-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, sameo@linux.intel.com
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:60971 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894Ab0GTKpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 06:45:30 -0400
In-Reply-To: <1279619434-11849-1-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2010-07-20 11:50, Luciano Coelho wrote:
> struct xt_condition_mtinfo {
>-	char name[31];
>+	char name[XT_CONDITION_MAX_NAME_SIZE];
> 	__u8 invert;
> 
> 	/* Used internally by the kernel */
> 	void *condvar __attribute__((aligned(8)));
> };
> 
>+struct condition_tg_info {

In the line of standardized naming, xt_condition_tginfo.

>+	char name[XT_CONDITION_MAX_NAME_SIZE];
>+	__u8 enabled;

No u32 yet?

>+static struct xt_target condition_tg_reg __read_mostly = {
>+       .name           = "CONDITION",
>+       .family         = NFPROTO_UNSPEC,
>+       .target         = condition_tg_target,
>+       .targetsize     = sizeof(struct condition_tg_info),
>+       .checkentry     = condition_tg_checkentry,
>+       .destroy        = condition_tg_destroy,
>+       .me             = THIS_MODULE,
>+};
>+
> static struct xt_match condition_mt_reg __read_mostly = {
>        .name       = "condition",
>        .revision   = 1,

(I see that you just sent a diff from the previous submission. That
in itself is ok.) Since xt_condition is a new module to upstream but
already exists in Xtables-addons, it makes sense to use a
.revision number of 2 for the initial Linux kernel submission,
also because the struct contents are different from those currently
in Xt-a.

>From an overall quick glance, looks good!
