From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: cleanup and optimization
Date: Fri, 13 Nov 2009 15:22:08 +0800
Message-ID: <412e6f7f0911122322w754f5686jac6c93d39fccab46@mail.gmail.com>
References: <4AFCF06B.1090602@gmail.com> <4AFD0707.50207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:45322 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbZKMHWD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:22:03 -0500
Received: by pwi3 with SMTP id 3so1844716pwi.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 23:22:08 -0800 (PST)
In-Reply-To: <4AFD0707.50207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 3:13 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> Changli Gao wrote:
>> act_mirred: cleanup and optimization.
>>
>> cleanup and optimization.
>> 1. don't let go back using goto.
>> 2. move checking if eaction is valid in tcf_mirred_init().
>> 3. don't call skb_act_clone() until it is necessary.
>> 4. one exit of the critical context.
>> 5. allow eaction is TCA_INGRESS_MIRROR & TCA_INGRESS_REDIR.
>>
>
>> =C2=A0 =C2=A0 =C2=A0 if (parm->ifindex) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev =3D __dev_get_by_ind=
ex(&init_net, parm->ifindex);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev =3D dev_get_by_index=
(&init_net, parm->ifindex);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dev =3D=3D NULL=
)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return -ENODEV;
>
> This change is not mentioned in the changelog and introduces a
> leak. Please split your patches into reasonable portions doing
> one change at a time.
>

Leak? Do I forget to put it some where? I'll keep it as a whole until
Jamal thinks it is in the right form and direction.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
