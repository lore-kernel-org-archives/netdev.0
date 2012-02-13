From: Vasily Averin <vvs@parallels.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot device
Date: Mon, 13 Feb 2012 15:20:02 +0400
Message-ID: <4F38F1E2.5010807@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Dmitry Kravkov" <dmitry@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36534 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333Ab2BMLU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 06:20:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael, Dmitry,

Could you please clarify how you have fixed this issue?
I've noticed very similar problem in CentOS6.2 environment,
could you please clarify how it's possible to fix or workaround it? 

thank you,
	Vasily Averin

On 10/27/2011 at 16:30 -0700, Michael Chan wrote:
> On Wed, 2011-10-19 at 13:53 -0700, John Fastabend wrote:
>> As a reference point this works fine in both FCoE and iSCSI stacks
>> today. The device is reset or link is lost for whatever reason
>> when the link comes back up the stack logs back in, enumerates
>> the luns and the scsi stack recovers as expected.
>>
>> Firmware should do the equivalent login, lun enumeration, etc as
>> needed.
> 
> Just a quick follow-up on this issue.  Our firmware actually performs
> the same logout before the reset and login after the reset.  For iSCSI,
> the problem on our device was actually caused by our userspace daemon
> logging events to a log file in the root fs.  The file I/O was blocked
> and the daemon could not proceed to do the important operations during
> the reset, and this caused filesystem I/O errors.  We have now fixed the
> problem in the userspace daemon.
> 
> For FCoE, there is no logging issue and the root fs failure seems to
> happen only in a multipath configuration with all paths going down for a
> short time (caused by reset in this case).  We believe this also affects
> other devices and not just ours.  We are now working with the multipath
> maintainer to understand this issue.
> 
> So this confirms that the original patch for bnx2x is not needed.
