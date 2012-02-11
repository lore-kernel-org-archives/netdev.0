From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v3 02/16] e100: Support RXFCS feature flag.
Date: Sat, 11 Feb 2012 17:07:41 +0100
Message-ID: <CAHXqBFJHoFd5W+YRn9bVg6RsqjFsTdaEM-MMdQjSwVVSckwS=A@mail.gmail.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com> <1328922274-23993-3-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65094 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab2BKQID convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 11:08:03 -0500
Received: by iacb35 with SMTP id b35so1771075iac.19
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2012 08:08:02 -0800 (PST)
In-Reply-To: <1328922274-23993-3-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/11  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
[...]
> @@ -1951,9 +1956,11 @@ static int e100_rx_indicate(struct nic *nic, s=
truct rx *rx,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Get actual data size */
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(dev->features & NETIF_F_RXFCS))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fcs_pad =3D 4;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0actual_size =3D le16_to_cpu(rfd->actual_si=
ze) & 0x3FFF;
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(actual_size > RFD_BUF_LEN - sizeo=
f(struct rfd)))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 actual_size =3D RF=
D_BUF_LEN - sizeof(struct rfd);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(actual_size > RFD_BUF_LEN + fcs_p=
ad - sizeof(struct rfd)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 actual_size =3D RF=
D_BUF_LEN + fcs_pad - sizeof(struct rfd);

BTW, Is this even triggered? I looks like this would indicate
corruption in the descriptor.

Best Regards,
Micha=C5=82 Miros=C5=82aw
