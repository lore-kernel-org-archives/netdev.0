From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by HW
Date: Sat, 15 Sep 2012 22:44:58 +0200
Message-ID: <CAHXqBFJZnGUSUutN=L-_LpCN7dXLPFY0ndJnQJ10NCcbzPVLww@mail.gmail.com>
References: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Tushar Dave <tushar.n.dave@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:41450 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab2IOUpT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 16:45:19 -0400
Received: by vcbfo13 with SMTP id fo13so5086813vcb.19
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2012 13:45:18 -0700 (PDT)
In-Reply-To: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/9/15 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> From: Tushar Dave <tushar.n.dave@intel.com>
>
> On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
> packets may get corrupted during padding by HW.
> To WA this issue, pad all small packets manually.
>
> Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/=
net/ethernet/intel/e1000/e1000_main.c
> index 3bfbb8d..bde337e 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3149,6 +3149,17 @@ static netdev_tx_t e1000_xmit_frame(struct sk_=
buff *skb,
>                 return NETDEV_TX_OK;
>         }
>
> +       /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
> +        * packets may get corrupted during padding by HW.
> +        * To WA this issue, pad all small packets manually.
> +        */
> +       if (skb->len < ETH_ZLEN) {
> +               if (skb_pad(skb, ETH_ZLEN - skb->len))
> +                       return NETDEV_TX_OK;
> +               skb->len =3D ETH_ZLEN;
> +               skb_set_tail_pointer(skb, ETH_ZLEN);
> +       }
> +

Isn't there a skb_padto() that does just this?

Best Regards,
Micha=B3 Miros=B3aw
