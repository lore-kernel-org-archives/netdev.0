From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN cmx: Avoid potential NULL deref in
 dsp_cmx_send_member() and shrink code size.
Date: Fri, 31 Dec 2010 11:19:15 -0800 (PST)
Message-ID: <20101231.111915.179940096.davem@davemloft.net>
References: <alpine.LNX.2.00.1012182322330.17400@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, julia@diku.dk, tj@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jolly@eversberg.eu
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012182322330.17400@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sat, 18 Dec 2010 23:33:40 +0100 (CET)

> Hi there,
> 
> In drivers/isdn/mISDN/dsp_cmx.c::dsp_cmx_send_member() we currently have 
> this code:
> 
>            if (dsp->conf && dsp->conf->software && dsp->conf->hardware)
>                    tx_data_only = 1;
>            if (dsp->conf->software && dsp->echo.hardware)
>                    tx_data_only = 1;
> 
> The first line implies that 'dsp->conf' may be NULL. If it is, then the 
> third line will dereference a NULL pointer.
> 
> This patch reworks the code so that we avoid the potential NULL deref.
> It also has the added benefit that the object file size shrinks a bit.
> 
> before:
>    text    data     bss     dec     hex filename
>   18840     112    5784   24736    60a0 drivers/isdn/mISDN/dsp_cmx.o
> after:
>    text    data     bss     dec     hex filename
>   18816     112    5776   24704    6080 drivers/isdn/mISDN/dsp_cmx.o
> 
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
