From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: bug fix for out-of-tree igb driver
Date: Wed, 4 May 2011 11:12:56 -0700
Message-ID: <BANLkTimdJr98ZbgxpfzqAS-w+MiyKSw-UA@mail.gmail.com>
References: <4DC1959B.4010609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64087 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755112Ab1EDSM5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:12:57 -0400
Received: by fxm17 with SMTP id 17so1020386fxm.19
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 11:12:56 -0700 (PDT)
In-Reply-To: <4DC1959B.4010609@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2011 at 11:06, Ben Greear <greearb@candelatech.com> wrot=
e:
> Just in case someone is using the out-of-tree igb driver, I
> think I found a bug.
>
> The tx_queue_mapping method should have r_idx >=3D adapter->num_tx_qu=
eues
> as shown below. =C2=A0The driver had: r_idx > adapter->num_tx_queues =
originally.
>
> Its possible my code is buggy for sending queue_mapping of 1
> when num_tx_queues is 1, but either way, the driver
> shouldn't crash.
>
> Upstream igb driver in mainline kernels does not have this problem.
>
> static inline struct igb_ring *igb_tx_queue_mapping(struct igb_adapte=
r
> *adapter,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int r_idx =3D skb->queue_mapping =
& (IGB_MAX_TX_QUEUES - 1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (r_idx >=3D adapter->num_tx_queues)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0r_idx =3D r_id=
x % adapter->num_tx_queues;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return adapter->tx_ring[r_idx];
> }
>
> Thanks,
> Ben
>

Thanks Ben, I have copied Carolyn so that she is aware of it.

--=20
Cheers,
Jeff
