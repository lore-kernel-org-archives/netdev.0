From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: kmemleak reports firmware loader funnies in iwlwifi
Date: Mon, 29 Jun 2009 12:48:29 +0300
Message-ID: <84144f020906290248w474ad2ffpe6a8b5bede3d2c20@mail.gmail.com>
References: <20090626171933.GA23170@redhat.com>
	 <tnxy6rbv0oq.fsf@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:50059 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbZF2Js1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 05:48:27 -0400
In-Reply-To: <tnxy6rbv0oq.fsf@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Catalin,

On Mon, Jun 29, 2009 at 12:39 PM, Catalin
Marinas<catalin.marinas@arm.com> wrote:
> diff --git a/drivers/base/firmware_class.c b/drivers/base/firmware_cl=
ass.c
> index ddeb819..26fb808 100644
> --- a/drivers/base/firmware_class.c
> +++ b/drivers/base/firmware_class.c
> @@ -179,6 +179,13 @@ static ssize_t firmware_loading_store(struct dev=
ice *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_er=
r(dev, "%s: vmap() failed\n", __func__);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto e=
rr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This block of memo=
ry is later freed using vfree.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Since kmemleak doe=
s not track vmap calls, just
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* inform it about th=
is block but ignore it during
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanning.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmemleak_alloc(fw_priv-=
>fw->data, 0, -1, GFP_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Pages will be freed=
 by vfree() */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fw_priv->pages =3D NUL=
L;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fw_priv->page_array_si=
ze =3D 0;

Would it be possible to put this hook in vmap() somehow?
