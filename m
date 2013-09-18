From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net RFC 2/2] ixgbe: fix sleep bug caused by napi_disable
 inside local_bh_disable()d context
Date: Thu, 19 Sep 2013 01:09:43 +0200
Message-ID: <20130918230943.GB11989@electric-eye.fr.zoreil.com>
References: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com>
 <20130918202016.8697.56423.stgit@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@intel.com>,
	Hyong-Youb Kim <hykim@myri.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50246 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036Ab3IRXKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 19:10:35 -0400
Content-Disposition: inline
In-Reply-To: <20130918202016.8697.56423.stgit@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jacob Keller <jacob.e.keller@intel.com> :
> This patch fixes a bug caused by calling napi_disable after local_bh_disable.
> It is possible for napi_disable to sleep, (though not guarunteed) so it could
> cause an atomic sleep bug during the  schedule() call in msleep. This patch
> resolves the issue by moving the local_bh_disable() calls inside the for loop
> in ixgbe_napi_disable_all().

Why couldn't you take mdelay(1) outside of the locally disabled bh section ?

-- 
Ueimor
