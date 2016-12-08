From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: gianfar: add ethtool eee support
Date: Thu, 8 Dec 2016 15:22:19 -0800
Message-ID: <2b309f6b-dcfd-006c-11ea-4fa2f35d01a5@gmail.com>
References: <1481196426-45576-1-git-send-email-Shaohui.Xie@nxp.com>
 <20161208.181922.957507188752351548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Shaohui.Xie@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33424 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbcLHXWW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 18:22:22 -0500
Received: by mail-pf0-f169.google.com with SMTP id d2so237703pfd.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 15:22:22 -0800 (PST)
In-Reply-To: <20161208.181922.957507188752351548.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2016 03:19 PM, David Miller wrote:
> From: Shaohui Xie <Shaohui.Xie@nxp.com>
> Date: Thu, 8 Dec 2016 19:27:06 +0800
> 
>> Gianfar does not support EEE, but it can connect to a PHY which supports
>> EEE and the PHY advertises EEE by default, and its link partner also
>> advertises EEE, so the PHY enters low power mode when traffic rate is low,
>> which causes packet loss if an application's traffic rate is low. This
>> patch provides .get_eee and .set_eee so that to disable the EEE
>> advertisement via ethtool if needed, other EEE features are not supported.
>>
>> Signed-off-by: Shaohui Xie <Shaohui.Xie@nxp.com>
> 
> This is not the way to fix this.
> 
> If the Gianfar MAC does not support EEE properly, then the gianfar
> driver should not create a situation where the PHY advertises EEE
> in the first place.

Agreed, you should have gianfar mask out the EEE advertisement from the
PHY it connects to, in order to make sure that EEE is properly disabled.
This should be no different from e.g: connecting a 10/100/1000 PHY to a
10/100 only controller for instance.
-- 
Florian
