From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 0/2] at803x: don't power-down SGMII link
Date: Tue, 25 Oct 2016 12:31:21 -0500
Message-ID: <580F96E9.8090208@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50551 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938295AbcJYRbX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 13:31:23 -0400
In-Reply-To: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi wrote:
> In a device where the ar8031 operates in SGMII mode, we
> observed that after a suspend-resume cycle in very rare
> cases the copper side autonegotiation secceeds but the
> SGMII side fails to come up.
>
> As a work-around, a patch was provided that on suspend and
> resume powers the SGMII link down and up along with the
> copper side. This fixed the observed failure, but
> introduced a regression Timur Tabi observed: once the SGMII
> is powered down, the PHY is inaccessible by the CPU and
> with that e.g. can't be re-initialized after suspend.
>
> Since the original issue could not be reproduced by others,
> this series provides an alternative handling:
> * the first patch reverts the prvious fix that powers down
>    SGMII
> * the second patch adds double-checking for the observed
>    failure condition
>
> Zefir Kurtisi (2):
>    Revert "at803x: fix suspend/resume for SGMII link"
>    at803x: double check SGMII side autoneg

Tested-by: Timur Tabi <timur@codeaurora.org>

With these patches, the problem I was seeing no longer occurs, and the 
new code does not appear to break anything.  As before, I still have 
never seen the original problem, but this patchset seems to work for 
both of us.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
