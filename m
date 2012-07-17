From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Resolve use of uninitialized memory
 in rxclass_get_dev_info
Date: Mon, 16 Jul 2012 17:10:08 -0700
Message-ID: <5004AD60.9090702@intel.com>
References: <20120713165221.28140.92681.stgit@gitlad.jf.intel.com> <1342469017.2523.33.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64840 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308Ab2GQAKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 20:10:09 -0400
In-Reply-To: <1342469017.2523.33.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2012 01:03 PM, Ben Hutchings wrote:
> On Fri, 2012-07-13 at 09:55 -0700, Alexander Duyck wrote:
>> The ethtool function for getting the rule count was not zeroing out the
>> data field before passing it to the kernel.  As a result the value started
>> uninitialized and was incorrectly returning a result indicating that
>> devices supported setting new rule indexes.  In order to correct this I am
>> adding a one line fix that sets data to zero before we pass the command to
>> the kernel.
> Right.  For 'get' commands with no parameters (besides the device) the
> data copied back to userland is normally zero-initialised and then
> filled out by the driver, and I seem to have worked on that assumption.
> But because of the odd multiplexing of RX NFC commands
> ETHTOOL_GRXCLSRLCNT doesn't work like that.  And for 'my' driver that
> didn't matter.  Sorry about that.
>
> (We should really have some explicit documentation of responsibility for
> structure initialisation.)
>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>
>> I am resending this since I didn't see any notification that it had been seen.
>> I also realized that I had not clearly identified that this is an ethtool user
>> space patch and not an ethtool kernel space patch.
> It was perfectly clear and I had queued it up to review but hadn't yet
> done so.
>
> Ben.
>
Yeah, that was my mistake.  I thought I hadn't sent it out with the
ethtool prefix when I actually had.

Thanks,

Alex
