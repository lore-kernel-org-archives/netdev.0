From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH net] net: nb8800: Fix SKB leak in nb8800_receive()
Date: Sat, 16 Jul 2016 12:01:03 +0100
Message-ID: <yw1xd1mdg840.fsf@unicorn.mansr.com>
References: <1468626084-31618-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Sebastian Frias <sf84@laposte.net>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-kernel@vger.kernel.org (open list)
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468626084-31618-1-git-send-email-f.fainelli@gmail.com> (Florian
	Fainelli's message of "Fri, 15 Jul 2016 16:41:16 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46lorian Fainelli <f.fainelli@gmail.com> writes:

> In case nb8800_receive() fails to allocate a fragment, we would leak =
the
> SKB freshly allocated and just return, instead, free it.
>
> Reported-by: coverity (CID 1341750)
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Mans Rullgard <mans@mansr.com>

> ---
>  drivers/net/ethernet/aurora/nb8800.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ether=
net/aurora/nb8800.c
> index 08a23e6b60e9..1a3555d03a96 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -259,6 +259,7 @@ static void nb8800_receive(struct net_device *dev=
, unsigned int i,
>  		if (err) {
>  			netdev_err(dev, "rx buffer allocation failed\n");
>  			dev->stats.rx_dropped++;
> +			dev_kfree_skb(skb);
>  			return;
>  		}
>
> --=20
> 2.7.4
>

--=20
M=E5ns Rullg=E5rd
