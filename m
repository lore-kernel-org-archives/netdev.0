From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] add fixed_phy_update_state() - update state of fixed_phy
Date: Fri, 03 Apr 2015 12:25:42 -0700
Message-ID: <551EE936.4010700@gmail.com>
References: <551C2AB9.8020508@list.ru> <551C2B37.6000100@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551C2B37.6000100@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/04/15 10:30, Stas Sergeev wrote:
> 
> Currently fixed_phy uses a callback to periodically poll the link state.
> This patch adds the fixed_phy_update_state() API.
> It solves the following problems:
> - On link state interrupt, MAC driver can't update status.
> Instead it needs to provide the callback to periodically query
> the HW about the link state. It is more efficient to update status
> after interrupt.
> - The callback needs to be unregistered before phy_disconnect(),
> or otherwise it will be called with net_dev==NULL. phy_disconnect()
> does not have enough info to unregister the callback automatically.
> - The callback needs to be registered before of_phy_connect() to
> avoid running with outdated state, but of_phy_connect() returns the
> phy_device pointer, which is needed to register the callback. Registering
> it before of_phy_connect() will therefore require a hack to get the
> pointer earlier.
> 
> Overall, this addition makes the subsequent patch that implements
> SGMII link status for mvneta, much cleaner.

Agreed, now that we have that, we should probably just remove the
ability to have a fixed link update callback since it suffers from all
the deficiencies you outlined above, and is creating some overhead by
polling the hardware.

Thanks!
-- 
Florian
