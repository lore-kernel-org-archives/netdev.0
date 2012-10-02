From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM
 Bladecenter SoL
Date: Tue, 2 Oct 2012 08:03:05 -0700
Message-ID: <1349190185.5420.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <87txuhho5z.fsf@lant.ki.iif.hu>
 <1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <87a9w5dqle.fsf@lant.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Rob Herring" <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org
To: "Ferenc Wagner" <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4675 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953Ab2JBPD2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 11:03:28 -0400
In-Reply-To: <87a9w5dqle.fsf@lant.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 14:07 +0200, Ferenc Wagner wrote:
> I'm done with bisecting it: the first bad commit is:
> 
> commit dabc5c670d3f86d15ee4f42ab38ec5bd2682487d
> Author: Matt Carlson <mcarlson@broadcom.com>
> Date:   Thu May 19 12:12:52 2011 +0000
> 
>     tg3: Move TSO_CAPABLE assignment
>     
>     This patch moves the code that asserts the TSO_CAPABLE flag closer
> to
>     where the TSO capabilities flags are set.  There isn't a good
> enough
>     reason for the code to be separated.
>     
>     Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
>     Reviewed-by: Michael Chan <mchan@broadcom.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks, I'll look into this.
> 
> On the other hand, losing the SoL console even temporarily during boot
> (as it happens with a minimal kernel before this commit) isn't nice
> either.  I'll try to look after that, too, just mentioning it here... 

This is expected as the driver has to reset the link and you'll lose SoL
for a few seconds until link comes back up.  We can look into an
enhancement to not touch the link if it is already in a good state when
the driver comes up.
