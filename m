From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: phy: unbind phy device from generic
 and specifical driver
Date: Mon, 26 Jan 2015 09:47:03 -0800
Message-ID: <54C67D97.7080203@gmail.com>
References: <1422260045-22527-1-git-send-email-b38611@freescale.com> <54C675F1.9080803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: Fugang Duan <b38611@freescale.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:54249 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbbAZRrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 12:47:21 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so13020254pad.4
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 09:47:21 -0800 (PST)
In-Reply-To: <54C675F1.9080803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/15 09:14, Florian Fainelli wrote:
> On 26/01/15 00:14, Fugang Duan wrote:
>> The current .phy_detach() function only unbind generic phy driver, which causes
>> specifical driver suspend/resume function still work like Atheros AT803X PHYs.
>>
>> For example:
>> ifconfig eth0 down
>> echo mem > /sys/power/status
>>
>> After eth0 interface down, driver call phy_detach to unbind phy driver, and then
>> do suspend/resume operation, at803x_suspend()/at803x_resume() functions still get
>> called that call mdio bus read/write function. When eth0 interface down, MAC driver
>> may close all clocks and mdio bus cannot work. So the issue happens.
> 
> I was just hitting this problem on Friday evening and was about to
> submit a similar change. Thanks!
> 
>>
>> The patch can unbind generic and specifical driver.
>>
>> Signed-off-by: Fugang Duan <B38611@freescale.com>
> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Humm, this breaks a sequence of ifconfig down then up, the driver is
removed, and we never get to probe it again, does this work for you
using the FEC driver?

Another way to solve this double suspend problem is to make sure that we
track whether the PHY has already been suspended.
-- 
Florian
