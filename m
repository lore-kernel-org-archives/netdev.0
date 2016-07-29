From: "Woodford, Timothy W." <Timothy.Woodford@jhuapl.edu>
Subject: RE: [Intel-wired-lan] [PATCH net-next v3 1/2] e1000e: factor out
 systim	sanitization
Date: Fri, 29 Jul 2016 14:40:54 +0000
Message-ID: <f236af8821e54127be4f1af2e8a998e9@APLEX07.dom1.jhuapl.edu>
References: <1469292274-59237-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-2-git-send-email-jarod@redhat.com>
 <8F4C390AFA9F4444A4AA77F4A3BEC78A190E7843@HASMSX110.ger.corp.intel.com>
 <c79639cd5a4c4907b83e2f5df50bd2bc@APLEX07.dom1.jhuapl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Woodford, Timothy W." <Timothy.Woodford@jhuapl.edu>,
	"Avargil, Raanan" <raanan.avargil@intel.com>,
	Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Hall, Christopher S" <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilot.jhuapl.edu ([128.244.251.36]:19554 "EHLO pilot.jhuapl.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547AbcG2OlI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 10:41:08 -0400
In-Reply-To: <c79639cd5a4c4907b83e2f5df50bd2bc@APLEX07.dom1.jhuapl.edu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> This is prepatory work for an expanding list of adapter families that have occasional ~10 hour clock jumps when being used for PTP. Factor out the sanitization function and convert to using a feature (bug) flag, per suggestion from Jesse Brandeburg.
>>> 
>>> Littering functional code with device-specific checks is much messier than simply checking a flag, and having device-specific init set flags as needed.
>>> There are probably a number of other cases in the e1000e code that could/should be converted similarly.
>> 
>> Looks ok to me.
>> Adding Chris who asked what happens if we reach the max retry counter (E1000_MAX_82574_SYSTIM_REREAD)?
>> This counter is set to 50. 
>> Can you, for testing purposes, decreased this value (or even set it to 0) and see what happens?
>  I'll set the max retry counter to 1 and run an overnight test to see what happens.

After running with this configuration for about 36 hours, I haven't seen any timing jumps.  Either this configuration eliminates the error, or it makes it significantly less likely to occur.

Tim Woodford
