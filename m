From: Stephen Torri <storri@torri.org>
Subject: Understanding the reason for placing a tcp_sock on stack in tcp
	network functions
Date: Mon, 28 Feb 2005 19:51:17 -0500
Message-ID: <1109638277.9693.15.camel@base.torri.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ij0+5vErWNLcZQY+QzRI"
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-ij0+5vErWNLcZQY+QzRI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I am trying to help out reducing the stack size of functions in the
kernel. The function names and values below, with comments and
questions, was obtained of the linux-2.6 kernel kept at bkbits.net when
I did 'make checkstack'.

I have one main question: must the variable 'sk' remained
unchanged in all these functions?

If so then copying the user_mss variable from that input struct 'sk' to
the tcp_sock created on the stack is ok. Otherwise why do we not use the
socket pointer 'sk'given as an argument via tcp_sk to cast the pointer
type to a tcp_sock pointer?

Stephen

--- Notes ---
# Status: Puts a tcp_sock on the stack each time the function
#         is executed. I don't know if the cost of a kmalloc
#         and free of a tcp_sock is more expensive in time
#         than creating a tcp_sock on the stack. The requirements
#         memory is most likely to the same for each (guess).
0xc025ac5c tcp_check_req:                               1208

# Status: Same report as tcp_check_req. Only question I have is
#         the tcp_sock contained in the struct sock* pointer 'sk'
#         need to be unmodified in this call? The reason I ask
#         is that there is supposedly a struct sock* pointer sent
#         to this function is a tcp_sock pointer. Calling tcp_sk(sk)
#         will cast the tcp_sock pointer. If its not required to
#         maintain 'sk' unchanged through this function then we
#         can skip adding one to the stack for the sole purpose of
#         copying the use_mms to it.
0xc02573da tcp_v4_conn_request:                         1192

# Status: Same report as tcp_check_req. Only comment here is that the
# struct sk_buff contains a reference to the socket that it is owned
# by. Again as with the comments with tcp_v4_conn_request, can we use
# the socket 'sk' contained in the sk_buff with tcp_sk(sk) to get a
# pointer to a tcp_sock? If we can then we are reusing a socket rather
# than creating one on the stack.

0xc02599c3 tcp_timewait_state_process:                  1176
0xc0259c9f tcp_timewait_state_process:                  1176

# Status: As the comments say in tcp_ipv6.c, this function is
# incredibly similar to the version in tcp_ipv4.c. Again why do have
# to create a tcp_sock header on the stack.

0x0001c713 tcp_v6_conn_request:                         1176

--=-ij0+5vErWNLcZQY+QzRI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCI7yFHN3s7YbuClYRAvN8AKCV7nX9zdrN7ij45+UOL27DaJ3u0gCgw4s4
HUuP7V90G7eG2KzyE1S3Llw=
=x0yq
-----END PGP SIGNATURE-----

--=-ij0+5vErWNLcZQY+QzRI--
