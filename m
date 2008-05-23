From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/3] cnic: Add CNIC driver.
Date: Fri, 23 May 2008 13:14:54 -0700
Message-ID: <adad4nc7p6p.fsf@cisco.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
	<1211418386-18203-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, michaelc@cs.wisc.edu, anilgv@broadcom.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:61200 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbYEWUQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 16:16:00 -0400
In-Reply-To: <1211418386-18203-3-git-send-email-mchan@broadcom.com> (Michael
	Chan's message of "Wed, 21 May 2008 18:06:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +		/* Tell compiler that status_blk fields can change. */
 > +		barrier();
 > +		if (status_idx != sblk->status_idx) {

Is a compiler barrier sufficient here?  It seems an out-of-order CPU
could still mess things up, so an rmb() or smp_rmb() would be required.
