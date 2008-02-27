From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] Marvell PHY m88e1111 driver fix
Date: Wed, 27 Feb 2008 17:15:14 -0600
Message-ID: <85A5C051-4A23-4FC3-B4D2-A3D61E60A811@freescale.com>
References: <20080227102118.GA29397@ru.mvista.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbordug@ru.mvista.com, mgreer@mvista.com
To: Alexandr Smirnov <asmirnov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:37460 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744AbYB0XQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 18:16:20 -0500
In-Reply-To: <20080227102118.GA29397@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 27, 2008, at 04:21, Alexandr Smirnov wrote:

> Hi All
>
>    Marvell PHY m88e1111 (not sure about other models, but think  
> they too) works
> in two modes: fiber and copper. In Marvell PHY driver (that we have  
> in current
> community kernels) code supported only copper mode, and this is not
> configurable, bits for copper mode are simply written in registers  
> during PHY
> initialization. This patch adds support for both modes.
>
>    According to 88e1111 manual: when phy is in copper mode,  
> register 22[7:0] = 0
> it selects copper banks of registers: 0, 1, 4, 5, 6, 7, 8, 17, 18,  
> 19; in fiber
> mode register 22[7:0] = 1 it selects the same banks of registers.  
> There is no
> register 10 (that is used in genphy_read_status() function) in  
> these banks.
>
>    Also as stated in manual register 10 is only for page 0 IOW  
> copper mode, and
> in fiber mode it probably contains wrong data (even when 22[7:0] = 1).
>
>    I tested this on several boards on where phy is connected in  
> fiber mode
> (SERDES). It doesn't work when genphy_read_status() is used.
>
>    At the moment I'm not sure if there's way of using  
> genphy_read_status()
> without any modifications to this function.


Yeah, if register 10 is page 0 only, it won't work for fiber.  It's  
annoying that the docs actually show it in both pages, but the  
register description says "page 0 only".  It's also annoying that  
they would thwart the 802.3 standard like that.  Anyway:

Acked-by: Andy Fleming <afleming@freescale.com>

Andy
