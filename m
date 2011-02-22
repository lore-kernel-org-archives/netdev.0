From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/2] qlcnic: fix type of module parameters
Date: Tue, 22 Feb 2011 10:31:47 -0800 (PST)
Message-ID: <20110222.103147.28828271.davem@davemloft.net>
References: <1298289514-15671-1-git-send-email-amit.salecha@qlogic.com>
	<1298289514-15671-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47077
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754786Ab1BVSbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 13:31:11 -0500
In-Reply-To: <1298289514-15671-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 21 Feb 2011 03:58:33 -0800

> o Module parameters auto_fw_reset, use_msi, use_msi_x, qlcnic_mac_learn,
>   and load_fw_file should be of type bool not int.
> o All module parameters should have qlcnic prefix.
> o Remove unnecessary macro for value "1".
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

You must not change module parameter names on a whim, as this will
break scripts.

When you create a module parameter in your driver, you are creating
something users will use, and therefore an API.  You therefore
cannot change it without breaking stuff.

This is yet another reason I scream at anyone who adds module
parameters to network drivers, they are always "the wrong thing
to do".

None of these values you guys have module parameter for in the
qlcnic driver are providing facilities that are really qlcnic
specific at all.

MSI-X enablement, firmware loading controls, etc.  All of this
stuff is generic and would be potentially necessary in any device
driver, not just qlcnic's.

Therefore generic facilities are where this stuff should be
implemented, instead of in driver specific module parameters.

I will not apply these patches, sorry.
