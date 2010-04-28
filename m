From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Wed, 28 Apr 2010 11:18:02 -0700
Message-ID: <k2w65634d661004281118t9fd212fbs8afc3a115bfffdea@mail.gmail.com>
References: <alpine.DEB.1.00.1004272332350.30235@pokey.mtv.corp.google.com>
	 <1272477251.18228.36.camel@Joe-Laptop.home>
	 <g2t65634d661004281107j676369c9ge379434723478c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:1107 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756220Ab0D1SSI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:18:08 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [10.3.21.2])
	by smtp-out.google.com with ESMTP id o3SII6bN003677
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 11:18:06 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq2.eem.corp.google.com with ESMTP id o3SII4DH029900
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 11:18:04 -0700
Received: by pwj8 with SMTP id 8so11369858pwj.24
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 11:18:03 -0700 (PDT)
In-Reply-To: <g2t65634d661004281107j676369c9ge379434723478c1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 28, 2010 at 11:07 AM, Tom Herbert <therbert@google.com> wro=
te:
>>
>> It might be better to test the comparisons using
>> a cpu_to_le32 of the constants.
>>
> Yes. =A0Probably should also be changed in nv_tx_done{_optimized} and
> nv_rx_process{_optimized}
>
Scratch that.  flags are checked all over the place in those other func=
tions.

>> static inline int nv_has_work(struct fe_priv *np)
>> {
>> =A0 =A0 =A0 =A0if (nv_optimized(np))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ((np->get_rx.ex !=3D np->put_r=
x.ex) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_rx.ex->flag=
len & cpu_to_le32(NV_RX2_AVAIL))) ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((np->get_tx.ex !=3D np-=
>put_tx.ex) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_tx.ex->flag=
len & cpu_to_le32(NV_TX_VALID)));
>>
>> =A0 =A0 =A0 =A0return ((np->get_rx.orig !=3D np->put_rx.orig) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_rx.orig->flaglen & cpu_to_l=
e32(NV_RX_AVAIL))) ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((np->get_tx.orig !=3D np->put_tx.orig) =
&&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(np->get_tx.orig->flaglen & cpu_to_l=
e32(NV_TX_VALID)));
>> }
>>
>>
>>
>
