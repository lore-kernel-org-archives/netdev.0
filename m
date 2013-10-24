From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH net-next] ppp: Allow ppp device connected to an l2tp
 session to change of namespace
Date: Thu, 24 Oct 2013 16:43:42 +0100
Message-ID: <5269402E.2070203@katalix.com>
References: <5268F6CD.9070600@alphalink.fr> <5268FCB1.7020903@katalix.com> <526923A7.8090108@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois_Cachereul?= <f.cachereul@alphalink.fr>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <526923A7.8090108@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24/10/13 14:41, Fran=E7ois Cachereul wrote:
> On 10/24/2013 12:55 PM, James Chapman wrote:
>> On 24/10/13 11:30, Fran=E7ois Cachereul wrote:
>>> Remove NETIF_F_NETNS_LOCAL flag from ppp device in ppp_connect_chan=
nel()
>>> if the device is connected to a l2tp session socket.
>>> Restore the flag in ppp_disconnect_channel().
>>
>> What about pppd's network namespace? Also, L2TP's tunnel socket (UDP=
 or
>> L2TP/IP) will be in a different namespace if the ppp interface is mo=
ved.
>=20
> That's what I'm trying to achieve. I'm not using pppd and my problem =
is
> as follow:  I need to isolate ppp devices from each other, even when
> they are connected to sessions carried by the same L2TP tunnel.

I'm thinking about the implications of a skb in the net namespace of th=
e
ppp interface passing through a tunnel socket which is in another
namespace. I think net namespaces are completely isolated.

To keep your ppp interfaces isolated from each other, have you
considered using netfilter to prevent data being passed between ppp
interfaces?

> Also, I
> need the authentication to be terminated to know the namespace in whi=
ch
> the ppp will be moved. For that, the process runs in a namespace with
> its l2tp sockets (tunnel and session) in that same namespace and each
> ppp device is moved in a specific namespace after authentication.
> =20
> Regards
> Fran=E7ois
>=20

--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
