From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH 02/14] SIWv2: iWARP Protocol headers: iwarp.h
Date: Sat, 18 Jun 2011 19:52:49 +0200
Message-ID: <BANLkTi=Z--Qq1TBymERFCcNWrO--cpeMmw@mail.gmail.com>
References: <1308228112-22582-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: Bernard Metzler <bmt@zurich.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f51.google.com ([209.85.212.51]:41944 "EHLO
	mail-vw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab1FRSAc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 14:00:32 -0400
In-Reply-To: <1308228112-22582-1-git-send-email-bmt@zurich.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2011 at 2:41 PM, Bernard Metzler <bmt@zurich.ibm.com> w=
rote:
> ---
> =A0drivers/infiniband/hw/siw/iwarp.h | =A0324 +++++++++++++++++++++++=
++++++++++++++
> =A01 files changed, 324 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/infiniband/hw/siw/iwarp.h
>
> diff --git a/drivers/infiniband/hw/siw/iwarp.h b/drivers/infiniband/h=
w/siw/iwarp.h
> [ ... ]
> +struct mpa_rr_params {
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> + =A0 =A0 =A0 __be16 =A0res:5,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 r:1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c:1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 m:1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rev:8;
> +#elif defined(__BIG_ENDIAN_BITFIELD)
> + =A0 =A0 =A0 __be16 =A0m:1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c:1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 r:1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res:5,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rev:8;
> +#else
> +#error "Adjust your <asm/byteorder.h> defines"
> +#endif
> + =A0 =A0 =A0 __be16 =A0pd_len;
> +};

The above style for declaring endianness specific bitfields in the
kernel is generally frowned upon. The preferred style is to declare a
__be32 or __le32 member variable, to define the bitmasks explicitly,
to use the __constant_cpu_to_be32() conversion function and friends
and to verify the resulting code with sparse (make C=3D1
CF=3D-D__CHECK_ENDIAN__ ...).

Bart.
