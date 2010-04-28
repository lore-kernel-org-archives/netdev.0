From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Wed, 28 Apr 2010 11:07:31 -0700
Message-ID: <g2t65634d661004281107j676369c9ge379434723478c1@mail.gmail.com>
References: <alpine.DEB.1.00.1004272332350.30235@pokey.mtv.corp.google.com>
	 <1272477251.18228.36.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:58857 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756109Ab0D1SHh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:07:37 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [10.3.21.12])
	by smtp-out.google.com with ESMTP id o3SI7YMT032059
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 11:07:35 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by hpaq12.eem.corp.google.com with ESMTP id o3SI70Xx019851
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 11:07:33 -0700
Received: by pvc21 with SMTP id 21so687224pvc.30
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 11:07:32 -0700 (PDT)
In-Reply-To: <1272477251.18228.36.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> It might be better to test the comparisons using
> a cpu_to_le32 of the constants.
>
Yes.  Probably should also be changed in nv_tx_done{_optimized} and
nv_rx_process{_optimized}

> static inline int nv_has_work(struct fe_priv *np)
> {
> =A0 =A0 =A0 =A0if (nv_optimized(np))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ((np->get_rx.ex !=3D np->put_rx=
=2Eex) &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_rx.ex->flagl=
en & cpu_to_le32(NV_RX2_AVAIL))) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((np->get_tx.ex !=3D np->=
put_tx.ex) &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_tx.ex->flagl=
en & cpu_to_le32(NV_TX_VALID)));
>
> =A0 =A0 =A0 =A0return ((np->get_rx.orig !=3D np->put_rx.orig) &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_rx.orig->flaglen & cpu_to_le=
32(NV_RX_AVAIL))) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((np->get_tx.orig !=3D np->put_tx.orig) &=
&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_tx.orig->flaglen & cpu_to_le=
32(NV_TX_VALID)));
> }
>
>
>
