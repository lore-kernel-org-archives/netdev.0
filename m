From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ip_tunnel: Move stats update to
 iptunnel_xmit()
Date: Thu, 24 Dec 2015 15:17:17 +0100
Message-ID: <567BFE6D.40803@6wind.com>
References: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
 <567BB917.9090900@6wind.com> <20151224124649.GB17571@indiana.gru.redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37952 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbbLXORU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 09:17:20 -0500
Received: by mail-wm0-f48.google.com with SMTP id l126so185955774wml.1
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 06:17:19 -0800 (PST)
In-Reply-To: <20151224124649.GB17571@indiana.gru.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/12/2015 13:46, Thadeu Lima de Souza Cascardo a =C3=A9crit :
> On Thu, Dec 24, 2015 at 10:21:27AM +0100, Nicolas Dichtel wrote:
>> Le 24/12/2015 00:52, Pravin B Shelar a =C3=A9crit :
>> [snip]
>>> diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
>>> index 6af78c6..d63a911 100644
>>> --- a/net/tipc/udp_media.c
>>> +++ b/net/tipc/udp_media.c
>>> @@ -182,15 +182,9 @@ static int tipc_udp_send_msg(struct net *net, =
struct sk_buff *skb,
>>>   			goto tx_error;
>>>   		}
>>>   		ttl =3D ip4_dst_hoplimit(&rt->dst);
>>> -		err =3D udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb,
>>> -					  src->ipv4.s_addr,
>>> -					  dst->ipv4.s_addr, 0, ttl, 0,
>>> -					  src->udp_port, dst->udp_port,
>>> -					  false, true);
>>> -		if (err < 0) {
>>> -			ip_rt_put(rt);
>>> -			goto tx_error;
>>> -		}
>>> +		udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb, src->ipv4.s_addr,
>>> +				    dst->ipv4.s_addr, 0, ttl, 0, src->udp_port,
>>> +				    dst->udp_port, false, true);
>> I don't know how tipc works, but this change is clearly suspect. Wha=
t make the
>> error path not needed anymore after your patch?
>
> I looked into it as well. As far as I see, err could only be positive=
 or 0, so
> if there is a tipc bug here, Pravin's patch introduces no regression.=
 Or did I
> fail to see how udp_tunnel_xmit_skb could return a negative value?
You're probably right. But I think it needs a separate patch in that ca=
se.


Regards,
Nicolas
