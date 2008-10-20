From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Mon, 20 Oct 2008 15:37:42 +0200
Message-ID: <1224509862.17450.309.camel@ecld0pohly>
References: <1224253423.17450.211.camel@ecld0pohly>
	 <200810182237.02373.opurdila@ixiacom.com>
	 <1224505645.17450.299.camel@ecld0pohly>
	 <200810201607.05758.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53462 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbYJTNjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2008 09:39:48 -0400
In-Reply-To: <200810201607.05758.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Octavian!

Seems like we agree on the way forward. I'll follow up with patches...

On Mon, 2008-10-20 at 07:07 -0600, Octavian Purdila wrote:
> > If that value is
> > not needed and computing it is considered to costly, a
> > SO_TIMESTAME_IS_HARDWARE could also be added.
>
> I didn't get this part.

For PTPd, access to the original hardware time stamps isn't necessary.
PTPd only needs to know whether the value returned by SO_TIMESTAMPNS was
created by hardware of software so that it can skip the ones done in
software. PTPd would use SO_TIMESTAMPNS + SO_TIMESTAMP_IS_HARDWARE, but
not SO_TIMESTAMP_HARDWARE.

Computing the original value can be costly, in particular when using the
advanced conversion to system time (okay, not that expensive, but
still...). Avoiding it when not necessary seems prudent.

There's one more argument in favor of adding both
SO_TIMESTAMP_IS_HARDWARE and SO_TIMESTAME_HARDWARE: as Andi mentioned in
a discussion I had with him today off the list, the link back to the
interface can get lost when a packet passes through complex IP filter
rules. SO_TIMESTAMP_IS_HARDWARE would always work while
SO_TIMESTAME_HARDWARE fails in this case.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

