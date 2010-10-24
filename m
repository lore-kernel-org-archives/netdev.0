From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan
 accleration.
Date: Sun, 24 Oct 2010 02:21:53 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B11FD@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
 <1287618974-4714-12-git-send-email-jesse@nicira.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429135@SJEXCHCCR02.corp.ad.broadcom.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429137@SJEXCHCCR02.corp.ad.broadcom.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE42913C@SJEXCHCCR02.corp.ad.broadcom.com>
 <AANLkTinudtxjGAEcc9cLjn+7Y7kqcaQXMW_5SRoNe5QU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hao Zheng" <hzheng@nicira.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Jesse Gross" <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2104 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932229Ab0JXJWM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 05:22:12 -0400
In-Reply-To: <AANLkTinudtxjGAEcc9cLjn+7Y7kqcaQXMW_5SRoNe5QU@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> >
> > We hit the same BUG() both when VLAN stripping is disabled.
> 
> This one surprises me because that function shouldn't get called at
> all when VLAN stripping is disabled.  Are you sure that it is
> disabled?  From my reading of the bnx2x driver it seems like it is
> always enabled.

I tried to check all possibilities and to check at which level the problem is,
so I patched the bnx2x not to do the stripping and recompiled it with the
kernel having CONFIG_VLAN_8021Q disabled. Then I saw the (same) BUG() message
again. It seems to me that your patch series were meant to remove the 
handling of this configuration (CONFIG_VLAN_8021Q) from the L2 drivers 
as well, isn't it? This means that the same VLAN flows, both accelerated and none
accelerated should be "active" both when this configuration is present and 
when it's not... Do I get it right?

Thanks,
vlad



