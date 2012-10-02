From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM Bladecenter SoL
Date: Tue, 02 Oct 2012 18:49:07 +0200
Message-ID: <87haqcddks.fsf@lant.ki.iif.hu>
References: <87txuhho5z.fsf@lant.ki.iif.hu>
	<1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<87a9w5dqle.fsf@lant.ki.iif.hu>
	<1349190185.5420.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Rob Herring" <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org, wferi@niif.hu
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349190185.5420.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	(Michael Chan's message of "Tue, 2 Oct 2012 08:03:05 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael Chan" <mchan@broadcom.com> writes:

> On Tue, 2012-10-02 at 14:07 +0200, Ferenc Wagner wrote:
>
>> I'm done with bisecting it: the first bad commit is:
>> 
>> commit dabc5c670d3f86d15ee4f42ab38ec5bd2682487d
>> Author: Matt Carlson <mcarlson@broadcom.com>
>> Date:   Thu May 19 12:12:52 2011 +0000
>> 
>>     tg3: Move TSO_CAPABLE assignment
>>     
>>     This patch moves the code that asserts the TSO_CAPABLE flag closer to
>>     where the TSO capabilities flags are set.  There isn't a good enough
>>     reason for the code to be separated.
>>     
>>     Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
>>     Reviewed-by: Michael Chan <mchan@broadcom.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Thanks, I'll look into this.

Going into the opposite direction: I found that Linux 3.6 does not
permanently break the SoL console on upping eth0!  I'll try to find the
commit which (sort of) fixed it.

>> On the other hand, losing the SoL console even temporarily during boot
>> (as it happens with a minimal kernel before this commit) isn't nice
>> either.  I'll try to look after that, too, just mentioning it here... 
>
> This is expected as the driver has to reset the link and you'll lose SoL
> for a few seconds until link comes back up.  We can look into an
> enhancement to not touch the link if it is already in a good state when
> the driver comes up.

This looks more complicated here.  In our production setup under 2.6.32
(stock Debian squeeze system) the SoL console is not broken during boot
at all.  I don't say there are no dropouts at all, but the management
system does not detach the console, like it promptly did during the
bisection in every case.  I could not reproduce this (preferred)
behavior with self-built kernels yet (not even with 2.6.18, which also
worked fine when built by Debian, if I remember correctly.  I'll
continue investigating this issue.
-- 
Thanks,
Feri.
