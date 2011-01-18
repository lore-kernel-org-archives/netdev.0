From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 19:24:40 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101181921320.17010@obet.zrqbmnf.qr>
References: <20110118172340.GB1843@del.dom.local> <AANLkTikUPRfYupw1-Py5mHeN+pFv-zMKhmK3DKixxsH4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>, pablo@netfilter.org,
	arthur.marsh@internode.on.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:51646 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867Ab1ARSYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 13:24:41 -0500
In-Reply-To: <AANLkTikUPRfYupw1-Py5mHeN+pFv-zMKhmK3DKixxsH4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2011-01-18 19:10, Alessandro Suardi wrote:
>On Tue, Jan 18, 2011 at 6:23 PM, Jarek Poplawski <jarkao2@gmail.com> w=
rote:
>>
>> NLM_F_DUMP flags should be applied to GET requests only, eg. rtnetli=
nk
>> tests message type to verify this. Since genetlink can't do the same
>> use "practical" test for ops->dumpit (assuming NEW request won't be
>> mixed with GET).
>>
>> - =C2=A0 =C2=A0 =C2=A0 if (nlh->nlmsg_flags & NLM_F_DUMP) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ops->dumpit =3D=
=3D NULL)
>> + =C2=A0 =C2=A0 =C2=A0 if (ops->dumpit) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nlh->nlmsg_fl=
ags & NLM_F_DUMP) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 genl_unlock();
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 err =3D netlink_dump_start(net->genl_sock, skb, nlh,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0ops->dumpit, ops->done);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 genl_lock();
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return err;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return -EOPNOTSUPP;
>> -
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 genl_unlock();
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D netlink_d=
ump_start(net->genl_sock, skb, nlh,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
ops->dumpit, ops->done);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 genl_lock();
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return err;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>
>2.6.37-git18 + netlink revert + this patch
> - fixes Avahi
> - breaks acpid
>Starting acpi daemon: RTNETLINK1 answers: Operation not supported
>acpid: error talking to the kernel via netlink

Deducing from that, it is a GET-like request that was sent by acpid,=20
and the message type is one that has both a dumpit and a doit function.
So if EOPNOTSUPP now occurs on all message types that have both dumpit=20
and doit, you should have broken a lot more than just acpid.
