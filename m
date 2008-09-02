From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND 2.6.27] netlink: Remove compat API for nested attributes
Date: Wed, 3 Sep 2008 01:20:09 +0200
Message-ID: <20080902232008.GD20815@postel.suug.ch>
References: <20080828140050.GB20815@postel.suug.ch> <20080828140527.GC20815@postel.suug.ch> <48BDB434.1040805@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43568 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbYIBXTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 19:19:50 -0400
Content-Disposition: inline
In-Reply-To: <48BDB434.1040805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Alexander Duyck <alexander.h.duyck@intel.com> 2008-09-02 14:46
> Thomas Graf wrote:
> >Removes all _nested_compat() functions from the API. The prio qdisc
> >no longer requires them and netem has its own format anyway. Their
> >existance is only confusing.
> >
> >Resend: Also remove the wrapper macro.
> >
> >Signed-off-by: Thomas Graf <tgraf@suug.ch>
> >
> I don't think we need to do anything as drastic as completely throwing 
> out this part of the Kernel ABI.  This is what I have been trying to get 
> at all along.  All we need to do is revert the two patches that we 
> talked about earlier and everything goes back to working.

Ever since the multiqueue bits have been removed from prio in net-next,
prio no longer requires the compat functions which leaves netem as the 
sole user. As you know, netem isn't really using the "compat" format but
instead uses its own format which was the origin of all this trouble.
Therefore I propose to move the current nla_parse_nested_compat() code
to netem and remove the API alltogether since there is no real user of
the original compat interface anymore. Leaving them around would only
encourage new code to use it.

Note that this patch is against the net-next tree which is not affected
by the prio regression (as the multiqueue bits have been removed) and
does not aim at resolving the regression. See my separate patch against
the stable tree which aims at resovling the prio regression.
Alternatively, reverting Patrick's and my patch in the stable tree is
perfectly fine with me as well.
