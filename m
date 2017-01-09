From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] phy state machine: failsafe leave invalid RUNNING
 state
Date: Sun, 8 Jan 2017 17:24:54 -0800
Message-ID: <5d0f7208-eec2-3b36-d946-e412ec051947@gmail.com>
References: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
 <1483701288-14019-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36265 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965017AbdAIBZA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 20:25:00 -0500
Received: by mail-qt0-f175.google.com with SMTP id k15so353864850qtg.3
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 17:25:00 -0800 (PST)
In-Reply-To: <1483701288-14019-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/06/2017 03:14 AM, Zefir Kurtisi wrote:
> While in RUNNING state, phy_state_machine() checks for link changes by
> comparing phydev->link before and after calling phy_read_status().
> This works as long as it is guaranteed that phydev->link is never
> changed outside the phy_state_machine().
> 
> If in some setups this happens, it causes the state machine to miss
> a link loss and remain RUNNING despite phydev->link being 0.
> 
> This has been observed running a dsa setup with a process continuously
> polling the link states over ethtool each second (SNMPD RFC-1213
> agent). Disconnecting the link on a phy followed by a ETHTOOL_GSET
> causes dsa_slave_get_settings() / dsa_slave_get_link_ksettings() to
> call phy_read_status() and with that modify the link status - and
> with that bricking the phy state machine.
> 
> This patch adds a fail-safe check while in RUNNING, which causes to
> move to CHANGELINK when the link is gone and we are still RUNNING.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
