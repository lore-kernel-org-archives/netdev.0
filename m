From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: io_error_detected callback should return
	PCI_ERS_RESULT_DISCONNECT on permanent failure
Date: Mon, 1 Jun 2009 16:43:39 -0700
Message-ID: <9929d2390906011643q3967535cue22345e6a40a4b14@mail.gmail.com>
References: <4A2050B8.7050302@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mike Mason <mmlnx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:63400 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbZFAXni convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 19:43:38 -0400
Received: by yw-out-2324.google.com with SMTP id 5so4482446ywb.1
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 16:43:40 -0700 (PDT)
In-Reply-To: <4A2050B8.7050302@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 2:16 PM, Mike Mason <mmlnx@us.ibm.com> wrote:
> PCI drivers that implement the io_error_detected callback
> should return PCI_ERS_RESULT_DISCONNECT if the state
> passed in is pci_channel_io_perm_failure. =C2=A0This state is not che=
cked in many
> of the network drivers.
>
> This patch fixes the omission in the e1000e driver.
>
> Signed-off-by: Mike Mason <mmlnx@us.ibm.com>
> --- a/drivers/net/e1000e/netdev.c =C2=A0 =C2=A0 =C2=A0 2009-05-23 14:=
47:00.000000000 -0700
> +++ b/drivers/net/e1000e/netdev.c =C2=A0 =C2=A0 =C2=A0 2009-05-29 13:=
43:24.000000000 -0700
> @@ -4616,6 +4616,9 @@ static pci_ers_result_t e1000_io_error_d
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_device_detach(netdev);
>
> + =C2=A0 =C2=A0 =C2=A0 if (state =3D=3D pci_channel_io_perm_failure)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return PCI_ERS_RES=
ULT_DISCONNECT;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (netif_running(netdev))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000e_down(ad=
apter);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
>
> --

Looks good.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=20
Cheers,
Jeff
