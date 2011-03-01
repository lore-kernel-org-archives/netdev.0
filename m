From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net-next-2.6] ethtool: Compat handling for struct
 ethtool_rxnfc
Date: Tue, 01 Mar 2011 00:10:33 +0000
Message-ID: <1298938233.2569.30.camel@bwh-desktop>
References: <1298930141.2569.22.camel@bwh-desktop>
	 <20110228235157.GG4669@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Santwona Behera <santwona.behera@sun.com>,
	netdev@vger.kernel.org
To: Kees Cook <kees.cook@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6939 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631Ab1CAAKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 19:10:36 -0500
In-Reply-To: <20110228235157.GG4669@outflux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 15:51 -0800, Kees Cook wrote:
> Hi Ben,
> 
> On Mon, Feb 28, 2011 at 09:55:41PM +0000, Ben Hutchings wrote:
> > I'm not sure whether more checks on rule_cnt are required for security
> > or whether compat_alloc_user_space() and copy_in_user() can be relied on
> > to limit any buffer overrun to the user process's own memory.  It looks
> > like this is safe on x86.
> 
> I'm less familiar with the compat world, but it looks sane to me. All the
> copy_in_user() calls are calculated based on structure sizes, right? Except
> for the rule_cnt one, which was already bounds-checked for output.
[...]

No, because the native ioctl implementation writes out the actual number
of rules to rxnfc->rule_cnt and we then read that back into rule_cnt
before performing the copy from rxnfc->rule_locs to
compat_rxnfc->rule_locs.  So userland can race with us and modify that
value.

We could use the original value of rule_cnt to calculate the size to
copy; it would just mean copying more than we need to most of the time.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

