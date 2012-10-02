From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM Bladecenter SoL
Date: Tue, 02 Oct 2012 20:49:15 +0200
Message-ID: <87626sd80j.fsf@lant.ki.iif.hu>
References: <87txuhho5z.fsf@lant.ki.iif.hu>
	<1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<87a9w5dqle.fsf@lant.ki.iif.hu>
	<1349190185.5420.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<87haqcddks.fsf@lant.ki.iif.hu>
	<1349197607.5420.25.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Rob Herring" <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org, wferi@niif.hu
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from listserv2.niif.hu ([193.225.14.155]:36253 "EHLO
	listserv2.niif.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294Ab2JBSt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:49:27 -0400
In-Reply-To: <1349197607.5420.25.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	(Michael Chan's message of "Tue, 2 Oct 2012 10:06:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael Chan" <mchan@broadcom.com> writes:

> On Tue, 2012-10-02 at 18:49 +0200, Ferenc Wagner wrote:
>
>> Going into the opposite direction: I found that Linux 3.6 does not
>> permanently break the SoL console on upping eth0!  I'll try to find
>> the commit which (sort of) fixed it.
>
> These are the likely fixes:
>
> commit cf9ecf4b631f649a964fa611f1a5e8874f2a76db 
> Author: Matt Carlson <mcarlson@broadcom.com>
> Date: Mon Nov 28 09:41:03 2011 +0000
>
> tg3: Fix TSO CAP for 5704 devs w / ASF enabled

You are exactly right: cf9ecf4b fixed the premanent SoL breakage
introduced by dabc5c67.  Looks like ASF utilizes similar technology to
that of the HS20 BMC.  Thanks for the tip, it greatly reduced our CPU
wear. :)  It's a pity ethtool -k did not give a hint.  Do you think it's
possible to work around in 3.2 by eg. fiddling some ethtool setting?
-- 
Thanks,
Feri.
