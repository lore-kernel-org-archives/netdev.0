From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot
 device
Date: Thu, 27 Oct 2011 16:30:35 -0700
Message-ID: <1319758235.7658.92.camel@HP1>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
 <20111019.160653.684945718064985511.davem@davemloft.net>
 <1319055172.7658.33.camel@HP1>
 <20111019.164702.1494656842101009040.davem@davemloft.net>
 <4E9F38D6.6030700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2924 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421Ab1J0Xkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 19:40:51 -0400
In-Reply-To: <4E9F38D6.6030700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2011-10-19 at 13:53 -0700, John Fastabend wrote:
> As a reference point this works fine in both FCoE and iSCSI stacks
> today. The device is reset or link is lost for whatever reason
> when the link comes back up the stack logs back in, enumerates
> the luns and the scsi stack recovers as expected.
> 
> Firmware should do the equivalent login, lun enumeration, etc as
> needed.

Just a quick follow-up on this issue.  Our firmware actually performs
the same logout before the reset and login after the reset.  For iSCSI,
the problem on our device was actually caused by our userspace daemon
logging events to a log file in the root fs.  The file I/O was blocked
and the daemon could not proceed to do the important operations during
the reset, and this caused filesystem I/O errors.  We have now fixed the
problem in the userspace daemon.

For FCoE, there is no logging issue and the root fs failure seems to
happen only in a multipath configuration with all paths going down for a
short time (caused by reset in this case).  We believe this also affects
other devices and not just ours.  We are now working with the multipath
maintainer to understand this issue.

So this confirms that the original patch for bnx2x is not needed.

Thanks.
