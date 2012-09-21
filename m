From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: bnx2x: link detected up at startup even when it should be down
Date: Fri, 21 Sep 2012 08:03:45 +0200
Message-ID: <CAL8zT=i_eV3SjuBgdWrBPaE-CoBBVh5QJD8jg-YMoQHDuA4AOQ@mail.gmail.com>
References: <CAL8zT=hFPQ-NZw8eKQwnktRrcpsOFk3aa_ac5mSWa+TAwyTGBQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Barak Witkowski <barak@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60886 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616Ab2IUGEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 02:04:07 -0400
Received: by ieak13 with SMTP id k13so4714388iea.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 23:04:06 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitry,

2012/9/20 Dmitry Kravkov <dmitry@broadcom.com>:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Jean-Michel Hautbois
>> Sent: Thursday, September 20, 2012 6:39 PM
>> To: netdev
>> Cc: Barak Witkowski; Eilon Greenstein; davem@davemloft.net
>> Subject: bnx2x: link detected up at startup even when it should be down
>>
>> Hi all,
>>
>> I am working with a HP blade which has a bnx2x based card (Broadcom
>> NetXtreme II BCM57810 10 Gigabit Ethernet).
>> I am using a 3.2 linux kernel, which works very well except on
>> detecting the link state at startup.
>> I have my ethernet interfaces linked with a bond, and I want to
>> configure it for HA (in miimon mode).
>> I am using a managed switch which helps me in disabling/enabling ports.
>>
>> When the port is disabled, at startup, the link is detected "UP".
>> When I enable the port, it is still "UP", and when I disable it again,
>> then it is detected "DOWN".
>>
>> I have tried the latest 3.6-rc6 kernel, and it works well (link is
>> "DOWN" at startup when port is disabled).
>> Then I bisected it, and I found out that the commit which makes it
>> working (yes, it is an inverse bisect, thanks to this powerful git
>> tool :)) is :
>>
>> a334872224a67b614dc888460377862621f3dac7 is the first bad commit
>> commit a334872224a67b614dc888460377862621f3dac7
>> Author: Barak Witkowski <barak@broadcom.com>
>> Date:   Mon Apr 23 03:04:46 2012 +0000
>>
>>     bnx2x: add afex support
>>
>>     Following patch adds afex multifunction support to the driver (afex
>>     multifunction is based on vntag header) and updates FW version
>> used to 7.2.51.
>>
>>     Support includes the following:
>>
>>     1. Configure vif parameters in firmware (default vlan, vif id, default
>>        priority, allowed priorities) according to values received from NIC.
>>     2. Configure FW to strip/add default vlan according to afex vlan mode.
>>     3. Notify link up to OS only after vif is fully initialized.
>>     4. Support vif list set/get requests and configure FW accordingly.
>>     5. Supply afex statistics upon request from NIC.
>>     6. Special handling to L2 interface in case of FCoE vif.
>>
>>     Signed-off-by: Barak Witkowski <barak@broadcom.com>
>>     Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> This commit is present in the 3.5.y stable branch, but not the 3.2.y one.
>> Is there a workaround which would make this feature work correctly
>> even on older kernels ?
>> It does not seem to be trivial, but I may miss something as this
>> driver is pretty big...
>
>  Jean,
> I have passed over the patch, but was unable to catch link related change out of the
> AFEX flow. We will get closer look asap in out lab (guys are out for the weekend already)
>
> Can you double check bisect result for me, pls?
>
> Thanks

I already did it twice. I think this is FW related and not only the
commit adding afex support. It may have solved a link issue (I am just
guessing, based on experiments) ?

JM
