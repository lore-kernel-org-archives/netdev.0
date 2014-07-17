From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net 1/1] net: ppp: fix creating PPP pass and
 active filters
Date: Wed, 16 Jul 2014 23:42:50 -0700 (PDT)
Message-ID: <20140716.234250.1209740744579611908.davem@davemloft.net>
References: <53C6DC35.3030400@kristov.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	paulus@samba.org, isdn@linux-pingi.de
To: develop@kristov.de
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <53C6DC35.3030400@kristov.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Schulz <develop@kristov.de>
Date: Wed, 16 Jul 2014 22:10:29 +0200

> From: Christoph Schulz <develop@kristov.de>
> 
> Commit 568f194e8bd16c353ad50f9ab95d98b20578a39d ("net: ppp: use
> sk_unattached_filter api") inadvertently changed the logic when setting
> PPP pass and active filters. This applies to both the generic PPP subsystem
> implemented by drivers/net/ppp/ppp_generic.c and the ISDN PPP subsystem
> implemented by drivers/isdn/i4l/isdn_ppp.c. The original code in ppp_ioctl()
> (or isdn_ppp_ioctl(), resp.) handling PPPIOCSPASS and PPPIOCSACTIVE allowed to
> remove a pass/active filter previously set by using a filter of length zero.
> However, with the new code this is not possible anymore as this case is not
> explicitly checked for, which leads to passing NULL as a filter to
> sk_unattached_filter_create(). This results in returning EINVAL to the caller.
> 
> Additionally, the variables ppp->pass_filter and ppp->active_filter (or
> is->pass_filter and is->active_filter, resp.) are not reset to NULL, although
> the filters they point to may have been destroyed by
> sk_unattached_filter_destroy(), so in this EINVAL case dangling pointers are
> left behind (provided the pointers were previously non-NULL).
> 
> This patch corrects both problems by checking whether the filter passed is
> empty or non-empty, and prevents sk_unattached_filter_create() from being
> called in the first case. Moreover, the pointers are always reset to NULL
> as soon as sk_unattached_filter_destroy() returns.
> 
> Signed-off-by: Christoph Schulz <develop@kristov.de>

Applied and queued up for -stable, thanks.
