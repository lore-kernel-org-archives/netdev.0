From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH 0/2] at803x: don't power-down SGMII link
Date: Thu, 27 Oct 2016 10:05:22 +0200
Message-ID: <2bf6fe19-5d18-ba96-5bf9-5030ace0ee89@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <580F96E9.8090208@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:11078 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942349AbcJ0OEv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 10:04:51 -0400
In-Reply-To: <580F96E9.8090208@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2016 07:31 PM, Timur Tabi wrote:
> Zefir Kurtisi wrote:
>> In a device where the ar8031 operates in SGMII mode, we
>> observed that after a suspend-resume cycle in very rare
>> cases the copper side autonegotiation secceeds but the
>> SGMII side fails to come up.
>>
>> As a work-around, a patch was provided that on suspend and
>> resume powers the SGMII link down and up along with the
>> copper side. This fixed the observed failure, but
>> introduced a regression Timur Tabi observed: once the SGMII
>> is powered down, the PHY is inaccessible by the CPU and
>> with that e.g. can't be re-initialized after suspend.
>>
>> Since the original issue could not be reproduced by others,
>> this series provides an alternative handling:
>> * the first patch reverts the prvious fix that powers down
>>    SGMII
>> * the second patch adds double-checking for the observed
>>    failure condition
>>
>> Zefir Kurtisi (2):
>>    Revert "at803x: fix suspend/resume for SGMII link"
>>    at803x: double check SGMII side autoneg
> 
> Tested-by: Timur Tabi <timur@codeaurora.org>
> 
> With these patches, the problem I was seeing no longer occurs, and the new code
> does not appear to break anything.  As before, I still have never seen the
> original problem, but this patchset seems to work for both of us.
> 
Thanks for testing.

I could make the double checking configurable and disabled by default, but this
would render it useless to detect the potential issue in the field.
