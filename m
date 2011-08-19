From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next v4 af-packet 2/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Fri, 19 Aug 2011 10:22:00 -0400
Message-ID: <CAAsGZS4H_np15HvoSwWYy3kN33Dk4rK+LE1i+xuTvv5O4ntE_w@mail.gmail.com>
References: <1313116260-1000-1-git-send-email-loke.chetan@gmail.com>
	<1313116260-1000-3-git-send-email-loke.chetan@gmail.com>
	<20110819.033613.1959565749346388734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:60599 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346Ab1HSOWB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:22:01 -0400
Received: by pzk37 with SMTP id 37so4915387pzk.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:22:00 -0700 (PDT)
In-Reply-To: <20110819.033613.1959565749346388734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 6:36 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Chetan Loke <loke.chetan@gmail.com>
> Date: Thu, 11 Aug 2011 22:31:00 -0400
>
>> +struct kbdq_ft_ops {
>> + =C2=A0 =C2=A0 int num_ops;
>> + =C2=A0 =C2=A0 void (*ft_ops[2])(void *, void *);
>> +};
> ...
>> + =C2=A0 =C2=A0 struct kbdq_ft_ops kfops;
> =C2=A0...
>> +static void prb_init_ft_ops(struct kbdq_core *p1,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 union tpacket_req_u *req_u)
>> +{
>> + =C2=A0 =C2=A0 p1->kfops.ft_ops[p1->kfops.num_ops++] =3D prb_fill_v=
lan_info;
>> +
>> + =C2=A0 =C2=A0 if (req_u->req3.tp_feature_req_word) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (req_u->req3.tp_featu=
re_req_word & TP_FT_REQ_FILL_RXHASH)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 p1->kfops.ft_ops[p1->kfops.num_ops++] =3D prb_fill_rxhash;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 p1->kfops.ft_ops[p1->kfops.num_ops++] =3D
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 prb_clear_rxhash;
>> + =C2=A0 =C2=A0 }
>> +}
>
> It is a lot cheaper to just test the flags in-line than do indirect c=
alls.
> Indirect calls are very expensive on many cpus.
>
> In fact, since the first op (prb_fill_vlan_info) is unconditional, we=
 eat
> the indirect call cost for absolutely no reason at all.

Oki. Will test the flags in-line in prb_run_all_ft_ops().


>
> This kfops stuff was not present in your previous changes. =C2=A0And =
I'm
> going to tell you that if you keep adding things each revision instea=
d
> of just fixing the specific items you've received feedback about, a
> set of changes this invasive and of this size will never get merged.
>

=46irst, thanks(to you and others) for reviewing the huge patchset. I
did think about breaking it into multiple patches but since it
involves changes in a single file it was a little difficult. And I
didn't want to create a separate file for this.

> Please resist the urge to further tinker with the code, and just
> address the feedback we give you.
>
Sorry won't happen. These changes should have been present in v3 when
I added the feature-request word because that was the intent of that
word. It was a screw up on my part.


Chetan Loke
