From: Ian Wienand <ianw@gelato.unsw.edu.au>
Subject: Default protocol for raw sockets
Date: Wed, 25 Feb 2004 14:59:34 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225035934.GK1200@cse.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ai3I8gwHc37+ASRI"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ai3I8gwHc37+ASRI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

man 7 packet states

  sll_protocol is the standard ethernet protocol type in network order
  as defined in the linux/if_ether.h include file.  It defaults to the
  socket's protocol.

But then later on says

  For bind only sll_protocol and sll_ifindex are used.

I'm unsure as to which is the expected behavour.  stracing the sample
program below shows that it does not pick up the protocol from the
socket.  (bind() also needs the sll_family filled in else it will fail
with an invalid argument).

I don't have a heap of experience with this; should bind pick up the
protocol from the socket or should the manpage be clarified?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--- sample program ---
strace shows

  socket(PF_PACKET, SOCK_RAW, 2144)       = 3
  bind(3, {sa_family=AF_PACKET, proto=0000, if0, ...
                                      ^^^^
#include <sys/socket.h>
#include <netpacket/packet.h>
#include <net/ethernet.h>

int main(void)
{
	struct sockaddr_ll sa;

	int s = socket(AF_PACKET, SOCK_RAW, htons(0x6008));

	bzero(&sa, sizeof(struct sockaddr_ll));

	sa.sll_family = AF_PACKET;
	sa.sll_ifindex = 0;

	bind(s, (struct sockaddr *)&sa, sizeof(struct sockaddr_ll));

	close(s);

	return 0;
}
--ai3I8gwHc37+ASRI
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAPB2mWDlSU/gp6ecRAhIBAJ4wSDfwfkxdgmQHtebqWu83OecMLQCeL+1X
OHf27s29R2bNzIVYbZuCGic=
=p4qK
-----END PGP SIGNATURE-----

--ai3I8gwHc37+ASRI--
