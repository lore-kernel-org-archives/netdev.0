From: Luciano Coelho <luciano.coelho@Nokia.com>
Subject: Re: [RFC v2] netfilter: xt_condition: add condition target
Date: Tue, 20 Jul 2010 14:04:15 +0300
Message-ID: <1279623855.16431.4.camel@powerslave>
References: <1279619434-11849-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1007201235250.20447@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:41704 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab0GTLFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 07:05:06 -0400
In-Reply-To: <alpine.LSU.2.01.1007201235250.20447@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-20 at 12:45 +0200, ext Jan Engelhardt wrote:
> On Tuesday 2010-07-20 11:50, Luciano Coelho wrote:
> > struct xt_condition_mtinfo {
> >-	char name[31];
> >+	char name[XT_CONDITION_MAX_NAME_SIZE];
> > 	__u8 invert;
> > 
> > 	/* Used internally by the kernel */
> > 	void *condvar __attribute__((aligned(8)));
> > };
> > 
> >+struct condition_tg_info {
> 
> In the line of standardized naming, xt_condition_tginfo.

Ack.


> >+	char name[XT_CONDITION_MAX_NAME_SIZE];
> >+	__u8 enabled;
> 
> No u32 yet?

Yes, I decided to make this in different steps.  I'll be submitting a
new patch with the u32 (and the binary operators support) pretty soon.


> >+static struct xt_target condition_tg_reg __read_mostly = {
> >+       .name           = "CONDITION",
> >+       .family         = NFPROTO_UNSPEC,
> >+       .target         = condition_tg_target,
> >+       .targetsize     = sizeof(struct condition_tg_info),
> >+       .checkentry     = condition_tg_checkentry,
> >+       .destroy        = condition_tg_destroy,
> >+       .me             = THIS_MODULE,
> >+};
> >+
> > static struct xt_match condition_mt_reg __read_mostly = {
> >        .name       = "condition",
> >        .revision   = 1,
> 
> (I see that you just sent a diff from the previous submission. That
> in itself is ok.) Since xt_condition is a new module to upstream but
> already exists in Xtables-addons, it makes sense to use a
> .revision number of 2 for the initial Linux kernel submission,
> also because the struct contents are different from those currently
> in Xt-a.

Yes, I made this patch on top of the one you have sent earlier for
upstream inclusion.  There were some comments from Patrick to that one
and, as I said in my email yesterday, I'll rebase the target patches
once the original one is included upstream.

Do you want me to take a look at Patrick's comments and resubmit the
patch you've sent with the changes Patrick asked for?

I'll change the revision to 2 as well.


> From an overall quick glance, looks good!

Thanks for your review and help on this!

-- 
Cheers,
Luca.

