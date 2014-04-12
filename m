From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [REGRESSION,BISECTED] mvneta broken in 3.14 on RN2120, RN102 and RN104 after e3a8786c10e7
Date: Sat, 12 Apr 2014 18:37:54 +0200
Message-ID: <87vbueo659.fsf@natisbad.org>
References: <87k3au8qba.fsf@natisbad.org> <20140412183112.7ca31cb6@skate>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:56966 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbaDLQiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2014 12:38:14 -0400
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp4-g21.free.fr (Postfix) with ESMTP id C1B494C8066
	for <netdev@vger.kernel.org>; Sat, 12 Apr 2014 18:38:04 +0200 (CEST)
In-Reply-To: <20140412183112.7ca31cb6@skate> (Thomas Petazzoni's message of
	"Sat, 12 Apr 2014 18:31:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

Thomas Petazzoni <thomas.petazzoni@free-electrons.com> writes:

>> I built a first kernel with the 'else' branch above removed (rationale:
>> SERDES config was not set for RGMII prior to the patch). The issue
>> remained.
>>      
>>     -       mvneta_gmac_rgmii_set(pp, 1);
>>     +       val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
>>     +
>>     +       val |= MVNETA_GMAC2_PCS_ENABLE | MVNETA_GMAC2_PORT_RGMII;
>> 
>> I removed MVNETA_GMAC2_PCS_ENABLE flag setting (rationale: it was only
>> done for SGMII prior to the patch and all my platforms have RGMII
>> connected PHY). *The issue disappeared on all 3 NAS with that simple
>> change*.
>
> Yes, issue known. See https://bugzilla.kernel.org/show_bug.cgi?id=73401.
>
> Unfortunately, at this point I don't have enough informations to fix
> both issues: the issue you're having, and the issue of using mvneta as
> a module. Since the issue you're having is much more problematic, I'll
> send a patch to revert my patch, until I have enough informations to
> fix the problem in a proper way.
>
> Thanks for your report!

Thanks for your work and the fast feedback. Do not hesitate to bug me if
you want me to do some tests at some point.

Cheers,

a+
