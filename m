From: Petr Kulhavy <petr@barix.com>
Subject: Re: davinci-mdio: failing to connect to PHY
Date: Mon, 4 Apr 2016 15:50:02 +0200
Message-ID: <5702710A.5010804@barix.com>
References: <57022356.6010309@barix.com> <20160404123145.GE21828@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34231 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbcDDNuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 09:50:06 -0400
Received: by mail-lf0-f53.google.com with SMTP id c62so171621890lfc.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 06:50:06 -0700 (PDT)
In-Reply-To: <20160404123145.GE21828@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04.04.2016 14:31, Andrew Lunn wrote:
>   
> Hi Petr
>
> You might want to take a look at:
>
> http://lxr.free-electrons.com/source/drivers/net/ethernet/ti/davinci_mdio.c#L137
>
> It seems to be asking the hardware about the phy mask.
>
>     Andrew

Hi Andrew,

thanks a lot for the link. In the meantime I've understood the issue 
better. It is due to the fact that the PHY is pin-strapped to address 1 
and broadcast (at address 0) is  enabled. The Micrel driver's 
config_init() disables the broadcast and the PHY stops responding, which 
causes the troubles. The kernel 3.17 didn't disable the broadcast and 
therefore it worked.

I'm wondering how to solve or workaround this...

Petr
