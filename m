From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 08/13] fsl/fman: check pcsphy pointer before use
Date: Tue, 4 Oct 2016 14:44:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01E2ED3@AcuExch.aculab.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
 <1475566379-5078-9-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linuxdev.baldrick@gmail.com" <linuxdev.baldrick@gmail.com>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "'madalin.bucur@nxp.com'" <madalin.bucur@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475566379-5078-9-git-send-email-madalin.bucur@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur
> Sent: 04 October 2016 08:33
> Subject: [net-next 08/13] fsl/fman: check pcsphy pointer before use
..
> --- a/drivers/net/ethernet/freescale/fman/fman_memac.c
> +++ b/drivers/net/ethernet/freescale/fman/fman_memac.c
> @@ -507,6 +507,9 @@ static void setup_sgmii_internal_phy(struct fman_mac *memac,
>  {
>  	u16 tmp_reg16;
> 
> +	if (WARN_ON(!memac->pcsphy))
> +		return;
> +

Why?

Either it can validly be NULL in which case you don't want the message.
Or it shouldn't be NULL in which case you need to find and fix the bug.
The later kernel OOPS will make the bug much easier to find.

	David
