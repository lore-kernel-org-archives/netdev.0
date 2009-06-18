From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH 4/9] sky2: fix shutdown synchronization
Date: Fri, 19 Jun 2009 08:25:03 +0900
Message-ID: <4A3ACCCF.1080605@ring3k.org>
References: <20090617173031.703636683@vyatta.com> <20090617173139.828049268@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:62927 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbZFRX0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 19:26:15 -0400
Received: by pxi27 with SMTP id 27so1387214pxi.33
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 16:26:18 -0700 (PDT)
In-Reply-To: <20090617173139.828049268@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Steven,

After applying your complete patch series, I'm still getting crashes in 
sky2_poll, and I can make them go away by adding an msleep(1) before 
these lines in sky2_down.

+	synchronize_irq(hw->pdev->irq);
+	napi_synchronize(&hw->napi);
+
  	sky2_phy_power_down(hw, port)

thanks,

Mike
