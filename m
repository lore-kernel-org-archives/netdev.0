From: Tom Gundersen <teg@jklm.no>
Subject: Re: panic with 2.6.37-rc1
Date: Wed, 3 Nov 2010 23:42:02 +0100
Message-ID: <AANLkTimY+cC=bu6LDb_e-Qbghd-F0RNZejhKaeXJWbY7@mail.gmail.com>
References: <AANLkTi=mEzCMCC+K6oLOjW9xfws_+_hHq8DS3hpPB1zY@mail.gmail.com> <1288822281.2718.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288822281.2718.30.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 3, 2010 at 11:11 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 03 novembre 2010 =C3=A0 23:02 +0100, Tom Gundersen a =C3=A9=
crit :
>> I get panic during boot both with 2.6.37-rc1 and with current head.
>>
>> Here is the error message:
>> <http://www.lix.polytechnique.fr/~tom/2.6.37-rc1-panic.jpg>. My
>> .config is below.
>>
>> Let me know if you want more info. If you want I can test patches or
>> bisect (if no one has any better suggestions).
>>
>
> Please test following patch, thanks
>
> [PATCH] atl1 : fix panic on load
>
> Its now illegal to call netif_stop_queue() before register_netdev()
>
> Reported-by: Tom Gundersen <teg@jklm.no>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0drivers/net/atlx/atl1.c | =C2=A0 =C2=A01 -
> =C2=A01 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index 43579b3..5336310 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -3043,7 +3043,6 @@ static int __devinit atl1_probe(struct pci_dev =
*pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atl1_pcie_patch(adapter);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* assume we have no link for now */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_carrier_off(netdev);
> - =C2=A0 =C2=A0 =C2=A0 netif_stop_queue(netdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0setup_timer(&adapter->phy_config_timer, at=
l1_phy_config,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
(unsigned long)adapter);
>
>

The patch solves the problem. Thanks!

Tom
