From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 05:36:15 +0100
Message-ID: <491D003F.7060605@cosmosbay.com>
References: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54185 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbYKNEgX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 23:36:23 -0500
In-Reply-To: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan a =E9crit :
>>> Something is wrong with read_pnet() as nobody suggested to mass use=
 it
>>> or send a patch doing it.
>> I did. My plan is to zap all superflous #ifdef CONFIG_NET_NS if poss=
ible.
>=20
> That's not mass usage.
>=20
> Mass usage is, say, s/dev_net/read_pnet/.
>=20
> Do you want to do this too?

Yes, it was present on my original first patch.
I said I was going to split the big patch.
How many mails will be necessary until you get the point ?

I was waiting *you* change "read_pnet()/write_pnet()" names as you
intended, *before* submitting new patches, in order not to
duplicate work.

=46or instance, I dont like :

static inline
struct net *dev_net(const struct net_device *dev)
{
#ifdef CONFIG_NET_NS
        return dev->nd_net;
#else
        return &init_net;
#endif
}


I prefer :

static inline
struct net *dev_net(const struct net_device *dev)
{
	return read_pnet(&dev->nd_net);
}

This is better because :

1) No #ifdef CONFIG_NET_NS

2) The magic about &init_net is not duplicated in ten different include=
 files, but
   centralized in the right file : include/net/net_namespace.h


