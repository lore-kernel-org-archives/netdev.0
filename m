From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM Bladecenter
 SoL
Date: Tue, 02 Oct 2012 23:06:58 +0400
Message-ID: <506B3B52.7080001@msgid.tls.msk.ru>
References: <87txuhho5z.fsf@lant.ki.iif.hu> <1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <87a9w5dqle.fsf@lant.ki.iif.hu> <1349190185.5420.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <87haqcddks.fsf@lant.ki.iif.hu> <1349197607.5420.25.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <87626sd80j.fsf@lant.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:59752 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013Ab2JBTHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 15:07:01 -0400
In-Reply-To: <87626sd80j.fsf@lant.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.10.2012 22:49, Ferenc Wagner wrote:
> "Michael Chan" <mchan@broadcom.com> writes:
>> These are the likely fixes:
>>
>> commit cf9ecf4b631f649a964fa611f1a5e8874f2a76db 
>> Author: Matt Carlson <mcarlson@broadcom.com>
>> Date: Mon Nov 28 09:41:03 2011 +0000
>>
>> tg3: Fix TSO CAP for 5704 devs w / ASF enabled
> 
> You are exactly right: cf9ecf4b fixed the premanent SoL breakage
> introduced by dabc5c67.  Looks like ASF utilizes similar technology to
> that of the HS20 BMC.  Thanks for the tip, it greatly reduced our CPU
> wear. :)  It's a pity ethtool -k did not give a hint.  Do you think it's
> possible to work around in 3.2 by eg. fiddling some ethtool setting?

Maybe it's better to push this commit to -stable instead? (the commit
that broke things is part of 3.0 kernel so all current 3.x -stable
kernels are affected)

(Besides, that commit "This patch fixes the problem by revisiting and
reevaluating the decision after tg3_get_eeprom_hw_cfg() is called." -
merely copies a somewhat "twisted" chunk of code into another place,
which does not look optimal)

Thanks,

/mjt
