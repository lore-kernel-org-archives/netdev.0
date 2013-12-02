From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: packet: use macro GET_PBDQC_FROM_RB to simplify the codes
Date: Mon, 02 Dec 2013 09:19:51 +0800
Message-ID: <529BE037.90006@cn.fujitsu.com>
References: <529712A7.3010604@cn.fujitsu.com> <52971A76.4020202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:11785 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752426Ab3LBBWZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:22:25 -0500
In-Reply-To: <52971A76.4020202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2013=C4=EA11=D4=C228=C8=D5 18:27, Daniel Borkmann =D0=B4=B5=C0:
> On 11/28/2013 10:53 AM, Duan Jiong wrote:
>>
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>=20
> Please resubmit when net-next is open.

How can i know when the net-next will be open?

>=20
>> ---
>>   net/packet/af_packet.c | 10 ++++++----
>>   1 file changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 2e8286b..955611f 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -430,7 +430,8 @@ static void prb_shutdown_retire_blk_timer(struct=
 packet_sock *po,
>>   {
>>   	struct tpacket_kbdq_core *pkc;
>>  =20
>> -	pkc =3D tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
>> +	pkc =3D tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring)
>> +		      : GET_PBDQC_FROM_RB(&po->rx_ring);
>=20
> Nit: the colon should actually still be on the previous line.
>=20
> It would be nice if at some point in time we could get rid of these T=
PACKET_V3 specific
> macros and actually use some inline functions.
>=20
>>  =20
>>   	spin_lock(&rb_queue->lock);
>>   	pkc->delete_blk_timer =3D 1;
>> @@ -456,7 +457,8 @@ static void prb_setup_retire_blk_timer(struct pa=
cket_sock *po, int tx_ring)
>>   	if (tx_ring)
>>   		BUG();
>>  =20
>> -	pkc =3D tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
>> +	pkc =3D tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring)
>> +		      : GET_RBDQC_FROM_RB(&po->rx_ring);
>>   	prb_init_blk_timer(po, pkc, prb_retire_rx_blk_timer_expired);
>>   }
>>  =20
>> @@ -514,7 +516,7 @@ static void init_prb_bdqc(struct packet_sock *po=
,
>>   			struct pgv *pg_vec,
>>   			union tpacket_req_u *req_u, int tx_ring)
>>   {
>> -	struct tpacket_kbdq_core *p1 =3D &rb->prb_bdqc;
>> +	struct tpacket_kbdq_core *p1 =3D GET_PBDQC_FROM_RB(rb);
>>   	struct tpacket_block_desc *pbd;
>>  =20
>>   	memset(p1, 0x0, sizeof(*p1));
>> @@ -578,7 +580,7 @@ static void _prb_refresh_rx_retire_blk_timer(str=
uct tpacket_kbdq_core *pkc)
>>   static void prb_retire_rx_blk_timer_expired(unsigned long data)
>>   {
>>   	struct packet_sock *po =3D (struct packet_sock *)data;
>> -	struct tpacket_kbdq_core *pkc =3D &po->rx_ring.prb_bdqc;
>> +	struct tpacket_kbdq_core *pkc =3D GET_PBDQC_FROM_RB(&po->rx_ring);
>>   	unsigned int frozen;
>>   	struct tpacket_block_desc *pbd;
>>  =20
>>
>=20
