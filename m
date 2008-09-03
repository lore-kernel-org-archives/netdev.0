From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RESEND 2.6.27] netlink: Remove compat API for nested attributes
Date: Tue, 02 Sep 2008 17:27:28 -0700
Message-ID: <48BDD9F0.8090706@intel.com>
References: <20080828140050.GB20815@postel.suug.ch> <20080828140527.GC20815@postel.suug.ch> <48BDB434.1040805@intel.com> <20080902232008.GD20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:52022 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254AbYICA13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 20:27:29 -0400
In-Reply-To: <20080902232008.GD20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> Ever since the multiqueue bits have been removed from prio in net-next,
> prio no longer requires the compat functions which leaves netem as the
> sole user. As you know, netem isn't really using the "compat" format but
> instead uses its own format which was the origin of all this trouble.
> Therefore I propose to move the current nla_parse_nested_compat() code
> to netem and remove the API alltogether since there is no real user of
> the original compat interface anymore. Leaving them around would only
> encourage new code to use it.

That is the point of code like this.  It defines a standard set of tools 
for extending an existing netlink interface.  If nothing else we should 
standardize on the netem approach for both parsing and creation since 
prio no longer ueses the compat attributes.

> Note that this patch is against the net-next tree which is not affected
> by the prio regression (as the multiqueue bits have been removed) and
> does not aim at resolving the regression. See my separate patch against
> the stable tree which aims at resovling the prio regression.
> Alternatively, reverting Patrick's and my patch in the stable tree is
> perfectly fine with me as well.

I saw your patches against the stable trees, and I would be happy with 
your solution or the reverting of the patches as long as one of them is 
implemented.

Thanks,

Alex
