From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH 14/14] ehea: Add GRO support
Date: Tue, 5 Apr 2011 14:29:14 -0700
Message-ID: <BANLkTiksELHr4Ln9pW_k4qcNcXBmBuT2aw@mail.gmail.com>
References: <20110405212825.6eb85677@kryten> <20110405214501.111d3638@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	michael@ellerman.id.au
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50263 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025Ab1DEV3f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 17:29:35 -0400
Received: by vws1 with SMTP id 1so646385vws.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 14:29:34 -0700 (PDT)
In-Reply-To: <20110405214501.111d3638@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 5, 2011 at 4:45 AM, Anton Blanchard <anton@samba.org> wrote=
:
> @@ -728,7 +716,14 @@ static int ehea_proc_rwqes(struct net_de
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0processed_bytes +=3D s=
kb->len;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ehea_proc_skb(pr, cqe, =
skb);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((cqe->status & EHEA=
_CQE_VLAN_TAG_XTRACT) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr->port->vgrp)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_gr=
o_receive(&pr->napi, pr->port->vgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 cqe->vlan_tag, skb);

Thank you for removing the old LRO code but the vlan-specific GRO
entry point is deprecated as well so please don't add new uses of it.
