From: "Belgazal, Netanel" <netanel@amazon.com>
Subject: Re: [PATCH net-next 12/13] net: ena: change validate_tx_req_id() to
 be inline function
Date: Mon, 19 Jun 2017 13:23:08 +0000
Message-ID: <1497878587980.81876@amazon.com>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
 <1497785298-13468-13-git-send-email-netanel@amazon.com>,<20170619045604.GJ17846@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Woodhouse, David" <dwmw@amazon.co.uk>,
        "Machulsky, Zorik" <zorik@amazon.com>,
        "Matushevsky, Alexander" <matua@amazon.com>,
        "BSHARA, Said" <saeedb@amazon.com>,
        "Wilson, Matt" <msw@amazon.com>,
        "Liguori, Anthony" <aliguori@amazon.com>,
        "Bshara, Nafea" <nafea@amazon.com>,
        "Schmeilin, Evgeny" <evgenys@amazon.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:57540 "EHLO
        smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbdFSNXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 09:23:19 -0400
In-Reply-To: <20170619045604.GJ17846@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The optimization purpose I mention was to inform the compiler to inline thi=
s function as there is only one caller to this function.=0A=
After reading the coding style you refer to I'll discard this patch.=0A=
=0A=
As a side note, I checked the disassembly code and I can see that gcc inlin=
e the function even without the explicit hint.=0A=
=0A=
Regards,=0A=
Netanel=0A=
________________________________________=0A=
From: Leon Romanovsky <leon@kernel.org>=0A=
Sent: Monday, June 19, 2017 7:56 AM=0A=
To: Belgazal, Netanel=0A=
Cc: davem@davemloft.net; netdev@vger.kernel.org; Woodhouse, David; Machulsk=
y, Zorik; Matushevsky, Alexander; BSHARA, Said; Wilson, Matt; Liguori, Anth=
ony; Bshara, Nafea; Schmeilin, Evgeny=0A=
Subject: Re: [PATCH net-next 12/13] net: ena: change validate_tx_req_id() t=
o be inline function=0A=
=0A=
On Sun, Jun 18, 2017 at 02:28:17PM +0300, netanel@amazon.com wrote:=0A=
> From: Netanel Belgazal <netanel@amazon.com>=0A=
>=0A=
> for optimization purpose, change validate_tx_req_id() to be=0A=
> inline function.=0A=
>=0A=
> Signed-off-by: Netanel Belgazal <netanel@amazon.com>=0A=
> ---=0A=
>  drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-=0A=
>  1 file changed, 1 insertion(+), 1 deletion(-)=0A=
>=0A=
> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/e=
thernet/amazon/ena/ena_netdev.c=0A=
> index 4540cd3d9f5f..da14b78cc87c 100644=0A=
> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c=0A=
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c=0A=
> @@ -698,7 +698,7 @@ static void ena_destroy_all_io_queues(struct ena_adap=
ter *adapter)=0A=
>       ena_destroy_all_rx_queues(adapter);=0A=
>  }=0A=
>=0A=
> -static int validate_tx_req_id(struct ena_ring *tx_ring, u16 req_id)=0A=
> +static inline int validate_tx_req_id(struct ena_ring *tx_ring, u16 req_i=
d)=0A=
=0A=
inline in C-file?=0A=
=0A=
Please read Documentation/process/coding-style.rst,=0A=
15) The inline disease" section why it is wrong and if you anyway=0A=
insists on doing it, please provide support of your claim "optimization=0A=
purposes" and show what and how exactly your optimization happened.=0A=
=0A=
Thanks=0A=
=0A=
=0A=
>  {=0A=
>       struct ena_tx_buffer *tx_info =3D NULL;=0A=
>=0A=
> --=0A=
> 2.7.4=0A=
>=0A=
