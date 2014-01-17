From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH V3 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag
 to IPV6_FL_A_GET
Date: Fri, 17 Jan 2014 13:16:55 +0100
Message-ID: <52D91F37.8060602@enst-bretagne.fr>
References: <1389889158-1710-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20140117012722.GA24345@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:34064 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480AbaAQMQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 07:16:57 -0500
In-Reply-To: <20140117012722.GA24345@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/01/2014 02:27, Hannes Frederic Sowa a =C3=A9crit :
> On Thu, Jan 16, 2014 at 05:19:16PM +0100, Florent Fourcot wrote:
>> @@ -1000,6 +1002,8 @@ static int tcp_v6_conn_request(struct sock *sk=
, struct sk_buff *skb)
>>  	ireq =3D inet_rsk(req);
>>  	ireq->ir_v6_rmt_addr =3D ipv6_hdr(skb)->saddr;
>>  	ireq->ir_v6_loc_addr =3D ipv6_hdr(skb)->daddr;
>> +	if (np->repflow)
>> +		np->flow_label =3D ip6_flowlabel(ipv6_hdr(skb));
>>  	if (!want_cookie || tmp_opt.tstamp_ok)
>>  		TCP_ECN_create_request(req, skb, sock_net(sk));
>> =20
>=20
> I am not sure here, do you write the flow_label on the listening sock=
et?
>=20

Hum, yes. You are right, this is bad.

One alternative is not so simple. Perhaps could we store the flowlabel
in inet_request_sock? It will be available in the tcp_v6_send_synack
function, even in case of retransmission.
