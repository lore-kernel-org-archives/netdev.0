From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net RFC 2/2] ixgbe: fix sleep bug caused by napi_disable
 inside local_bh_disable()d context
Date: Thu, 19 Sep 2013 22:28:48 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58565F5E52@ORSMSX104.amr.corp.intel.com>
References: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com>
 <20130918202016.8697.56423.stgit@jekeller-desk1.amr.corp.intel.com>
 <20130918230943.GB11989@electric-eye.fr.zoreil.com>
 <02874ECE860811409154E81DA85FBB58565F1520@ORSMSX104.amr.corp.intel.com>
 <20130919213254.GC31672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Hyong-Youb Kim <hykim@myri.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25295 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183Ab3ISW2x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 18:28:53 -0400
In-Reply-To: <20130919213254.GC31672@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Thursday, September 19, 2013 2:33 PM
> To: Keller, Jacob E
> Cc: netdev@vger.kernel.org; Duyck, Alexander H; Hyong-Youb Kim;
> Dmitry Kravkov; Amir Vadai; Eliezer Tamir
> Subject: Re: [PATCH net RFC 2/2] ixgbe: fix sleep bug caused by
> napi_disable inside local_bh_disable()d context
> 
> Keller, Jacob E <jacob.e.keller@intel.com> :
> [...]
> > I know that we need local_bh_disable around the qv_lock_napi code
> because
> > it uses spin_lock instead of spin_lock_bh. I believe the reason we need
> bh
> > disabled around the entire context is so that the small window between
> > failed calls to qv_lock_napi don't get interrupted and continue to have
> > busy_poll lock the q_vector over and over.
> 
> Thanks for explaining the intent. I'll do my homework.
> 

Thanks. Again, I am not entirely sure this is the right solution, (hence the RFC) because I am not that familiar with the code here.

> > I have to move the local_bh_disable in order to put napi_disable
> outside
> > of the call since napi_disable could sleep, causing a scheduling while
> > atomic BUG.
> 
> I am in violent agreement with this part.
> --
> Ueimor

Regards,
Jake
