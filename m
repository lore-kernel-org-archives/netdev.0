From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/1] ixgbe: fcoe: return value of
        skb_linearize should be handled
Date: Thu, 8 Dec 2016 01:32:47 +0000
Message-ID: <1C8B930C-8697-41FA-BFCF-22168963C252@intel.com>
References: <1481096614-25295-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_38A992A5-981C-4A01-9998-EF904FC48C12";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481096614-25295-1-git-send-email-zhouzhouyi@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_38A992A5-981C-4A01-9998-EF904FC48C12
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index fee1f29..4926d48 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -2173,8 +2173,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector  
> *q_vector,
>  				total_rx_bytes += ddp_bytes;
>  				total_rx_packets += DIV_ROUND_UP(ddp_bytes,
>  								 mss);
> -			}
> -			if (!ddp_bytes) {
> +			} else {
>  				dev_kfree_skb_any(skb);
>  				continue;
>  			}

This is changing the logic by treating a negative ddp_bytes value (an error  
return) the same as a 0 value. This is probably wrong and inappropriate for  
this patch in any case.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_38A992A5-981C-4A01-9998-EF904FC48C12
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJYSLg/AAoJEDwO/+eO4+5u2rMQAKekwArC1cgsTFT9PiXtXSxT
1Ab8r9cV8h6lBid0ok4qcSAOkHbcw0bbOqSMjlLBQ6/ddvxKZSlqcf6UksqJxvzI
8xPoIPebXefkj+w4HY1ulRwEbwiC5RZQlQhK7ISwwrzEeylunMsZA1ul0hovabI0
ddh46rlQ3SdfXiQAFlLNVXrFJ1jJdUFXbp11uml4yoJydMhB+6/bxyrLXY8W3ZI2
NH8SKOrmncWop4a+ickEp+zCddtfsx7EHzqRdJTMY6zc7j/RBlsVaO+zSvp+NydL
oA6h/AvdEV1/GdjtAgO/aqN6iar3/kU5w8nnQNv3QckXXEoFyPWfZ6+qglNhHmpC
6MMQnPFgGPYF9Z1h/kQ1ZnE7kJqOOIi7jS3nnFxq0N+w1RG0nqa2aQzHZgWUB6t5
ruV+k/zm6WOZ9rByrwKMxsrDsZR8OvEC2Y/44W9EJlvZIYemqnr5+6MMDHT68ihE
EDiz724ztbffZklUX2WOtN3e+HYBTuvTtfcjY4w3BRxFS/wNGswzs2Rs6faGK0r/
Cp6l81S+efzchLmudcY6AS0JuywGnWspzUQQ6TWYr9HZhEcBEwO9JQSlSTA5JFAM
6lxMPZO9BhaFoq7NhiwdI9Ifk6XyrgtQzqOOujRzsFwF1B6b7LzKLe1Q7ah0LpCP
eP26bZVhyShX2APsh/3H
=IoRf
-----END PGP SIGNATURE-----

--Apple-Mail=_38A992A5-981C-4A01-9998-EF904FC48C12--
