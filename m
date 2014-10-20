From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH] drivers: net: xgene: Add missing initialization in xgene_enet_ecc_init()
Date: Mon, 20 Oct 2014 11:20:09 -0700
Message-ID: <CAKh23F=2nNC8TkD-ftzfZ-pLEKG0CuwZ=RkX5O4aoOu4Y45Xpw@mail.gmail.com>
References: <1413792496-8558-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Keyur Chudgar <kchudgar@apm.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og124.obsmtp.com ([64.18.0.212]:48305 "HELO
	exprod5og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751511AbaJTSUM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 14:20:12 -0400
Received: by mail-lb0-f176.google.com with SMTP id p9so4299381lbv.7
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 11:20:09 -0700 (PDT)
In-Reply-To: <1413792496-8558-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2014 at 1:08 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c: In function =E2=80=
=98xgene_enet_ecc_init=E2=80=99:
> drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c:126: warning: =E2=80=
=98data=E2=80=99 may be used uninitialized in this function
>
> Depending on the arbitrary value on the stack, the loop may terminate
> too early, and cause a bogus -ENODEV failure.
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/driv=
ers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
> index e6d24c2101982444..19e13583b4259cd4 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
> @@ -123,7 +123,7 @@ static u32 xgene_enet_rd_mac(struct xgene_enet_pd=
ata *p, u32 rd_addr)
>  static int xgene_enet_ecc_init(struct xgene_enet_pdata *p)
>  {
>         struct net_device *ndev =3D p->ndev;
> -       u32 data;
> +       u32 data =3D 0;
>         int i;
>
>         xgene_enet_wr_diag_csr(p, ENET_CFG_MEM_RAM_SHUTDOWN_ADDR, 0);
> --
> 1.9.1
>

Acked-by: Iyappan Subramanian <isubramanian@apm.com>
