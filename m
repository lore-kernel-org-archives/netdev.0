From: Jan Dittmer <j.dittmer@portrix.net>
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 13:54:44 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <416A7484.1030703@portrix.net>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org,
	hermes@gibson.dropbear.id.au
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268824AbUJKLzY@vger.kernel.org>
To: Cal Peake <cp@absolutedigital.net>
In-Reply-To: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net>
List-Id: netdev.vger.kernel.org

Cal Peake wrote:
> Hi,
> 
> This patch fixes several dozen warnings spit out when compiling the hermes 
> wireless driver.
> 
> In file included from drivers/net/wireless/orinoco.c:448:
> drivers/net/wireless/hermes.h: In function `hermes_present':
> drivers/net/wireless/hermes.h:398: warning: passing arg 1 of `readw' makes pointer from integer without a cast
> drivers/net/wireless/hermes.h: In function `hermes_set_irqmask':
> drivers/net/wireless/hermes.h:404: warning: passing arg 2 of `writew' makes pointer from integer without a cast
> ...

>  	inw((hw)->iobase + ( (off) << (hw)->reg_spacing )) : \
> -	readw((hw)->iobase + ( (off) << (hw)->reg_spacing )))
> +	readw((void __iomem *)(hw)->iobase + ( (off) << (hw)->reg_spacing )))
>  #define hermes_write_reg(hw, off, val) do { \

Isn't the correct fix to declare iobase as (void __iomem *) ?

Thanks,

Jank
