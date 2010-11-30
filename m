From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] af_packet: replace struct pgv with char **
Date: Tue, 30 Nov 2010 22:30:32 +0800
Message-ID: <AANLkTi=e=XN7vZKepDoKz8FUavmj4p3pjE05GzDy8is0@mail.gmail.com>
References: <1291125457-14427-1-git-send-email-xiaosuo@gmail.com> <1291126568.2904.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59083 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821Ab0K3Oay convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 09:30:54 -0500
Received: by fxm8 with SMTP id 8so1204020fxm.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 06:30:52 -0800 (PST)
In-Reply-To: <1291126568.2904.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 10:16 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 30 novembre 2010 =E0 21:57 +0800, Changli Gao a =E9crit :
>> As we can check if an address is vmalloc address with is_vmalloc_add=
r(),
>> we can replace struct pgv with char **. Then we may get more pg_vecs=
=2E
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0net/packet/af_packet.c | =A0 50 ++++++++++++++++-----------------=
----------------
>> =A01 file changed, 17 insertions(+), 33 deletions(-)
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 0171b20..a26f981 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -164,14 +164,8 @@ struct packet_mreq_max {
>> =A0static int packet_set_ring(struct sock *sk, struct tpacket_req *r=
eq,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int closing, int tx_ring);
>>
>> -#define PGV_FROM_VMALLOC 1
>> -struct pgv {
>> - =A0 =A0 char *buffer;
>> - =A0 =A0 unsigned char flags;
>> -};
>> -
>
> This patch is premature.
>
> Also, keep the struct pgv, even if it has a single field, since havin=
g
> types is good to read the sources.
>
> We could have 'void *' or 'char *' everywhere, it is not nice...
>
>
> - =A0 =A0 =A0 pg_vec =3D kcalloc(block_nr, sizeof(struct pgv), GFP_KE=
RNEL);
> + =A0 =A0 =A0 pg_vec =3D kcalloc(block_nr, sizeof(char *), GFP_KERNEL=
);
>
> I prefer to have :
>
> =A0 =A0 =A0 pg_vec =3D kcalloc(block_nr, sizeof(struct pgv), GFP_KERN=
EL);
>

OK. I'll respin it and the previous one in the same serial to address
the issues mentioned by you. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
