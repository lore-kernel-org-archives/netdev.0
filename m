From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 15/17] fm10k: fix possible null pointer deref after
 kcalloc
Date: Thu, 21 Apr 2016 19:44:24 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857A7C1E0@ORSMSX115.amr.corp.intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1461218969-68578-16-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21276 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753600AbcDUTo0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:44:26 -0400
In-Reply-To: <1461218969-68578-16-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Kirsher, Jeffrey T
> Sent: Wednesday, April 20, 2016 11:09 PM
> To: davem@davemloft.net
> Cc: Keller, Jacob E <jacob.e.keller@intel.com>; netdev@vger.kernel.org;
> nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com;
> Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Subject: [net-next 15/17] fm10k: fix possible null pointer deref after kcalloc
> 
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> When writing a new default redirection table, we needed to populate
> a new RSS table using ethtool_rxfh_indir_default. We populated this
> table into a region of memory allocated using kcalloc, but never checked
> this for NULL. Fix this by moving the default table generation into
> fm10k_write_reta. If this function is passed a table, use it. Otherwise,
> generate the default table using ethtool_rxfh_indir_default, 4 at at
> time.
> 
> Fixes: 0ea7fae44094 ("fm10k: use ethtool_rxfh_indir_default for default
> redirection table")
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Hi Dave, and Jeff,

Dave, please don't pull this patch. Krishneil found an issue with this patch, and I sent a corrected fix to squash in but it didn't make it into this one. I'd like to get the fix squashed in a resend before this is pulled into net-next.

Thanks,
Jake
