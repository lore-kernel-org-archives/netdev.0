From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: smsc911x: Fix register_netdev, phy startup
 ordering and driver unload
Date: Thu, 16 Jun 2016 19:14:06 +0300
Message-ID: <985f76c2-ed63-add2-bc24-fd4a6c3f8153@cogentembedded.com>
References: <1466092480-21005-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, andrew@lunn.ch
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34382 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbcFPQOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 12:14:11 -0400
Received: by mail-lf0-f41.google.com with SMTP id j7so43845323lfg.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 09:14:10 -0700 (PDT)
In-Reply-To: <1466092480-21005-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/16/2016 06:54 PM, Jeremy Linton wrote:

> Previously the mdio and phy's were started in the drv probe following
> register_netdev(). This could lead to a situation where if the netdev was
> opened before the mdio/phys were configured, it would fail with a
> EAGAIN.
>
> Also, the use of phy_connect_direct() in the drv_probe
> routine results in a situation where the module use count would never
> decrease sufficiently to unload the driver.

    It's a bad idea to fix 2 issues with one patch (unless they are caused by 
the same reason). "Do one thing per patch" is a rule of thumb here...

> With this patch the mdio bus is allocated/configured before
> register_netdev(), and the phy's are brought online/started in the
> ndo_open and stopped in the ndo_stop. Because of this, the behavior
> of ethtool changes a little if the interface is stopped. Before the
> phy's would remain up, and their last state would be displayed with
> ethtool. Now ethtool reports link has been severed/Link detected: no
> when the net dev is stopped.
>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>[...]

[...]

MBR, Sergei
