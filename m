From: =?ISO-8859-15?Q?Niccol=F2_Belli?= <darkbasic-DEeHIYRtcplPMsqi6aon0Q@public.gmane.org>
Subject: Strange issue with IPv6 through ipsec
Date: Thu, 01 Mar 2012 00:43:28 +0100
Message-ID: <4F4EB820.1090607@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: users-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <users-bounces+gnvsu-users=m.gmane.org-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.strongswan.org/mailman/listinfo/users>,
	<mailto:users-request-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.strongswan.org/pipermail/users>
List-Post: <mailto:users-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:users-request-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://lists.strongswan.org/mailman/listinfo/users>,
	<mailto:users-request-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: users-bounces+gnvsu-users=m.gmane.org-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org
Errors-To: users-bounces+gnvsu-users=m.gmane.org-3+4lAyCyj6DkhV4RL1hkzWD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,
I'm not sure if netdev is the right place, that's a strange behavior but =

I'm not sure if it's a bug because I'm an IPv6 newbie.

I'd like to give my servers IPv6 connectivity for the World IPv6 Launch, =

so I bought a virtual machine with IPv6 connectivity and I asked to =

route a /56, then I extruded it through an IKEv2 ipsec tunnel =

(Strongswan 4.5.3 on Debian Squeeze amd64).

A is the virtual machine with IPv6 connectivity.
B is the other peer.
A has IPv6 a:b:c:d::1/64
The routed subnet is a:b:c:300::/56

After the tunnel creation I add an IPv6 to B external interface:
ip -6 addr add a:b:c:301::1/6 dev nas0
Then I create a default route:
ip -6 route add default via a:b:c:0301::2 dev nas0

Now I can ping A from B and B from A.
If I destroy and re-create the tunnel everything keep working.

If instead of adding an IPv6 to nas0 I add it to eth0 (an internal =

interface):
ip -6 addr add a:b:c:301::1/6 dev eth0
ip -6 route add default via a:b:c:0301::2 dev eth0

it still works (A con ping B and B can ping A) *BUT* if I destroy and =

re-create the tunnel it doesn't work anymore!
I have to type:
ip -6 addr del a:b:c:301::1/6 dev eth0
ip -6 addr add a:b:c:301::1/6 dev eth0
ip -6 route add default via a:b:c:0301::2 dev eth0

to make it work again O_O

Cheers,
Niccol=F2
