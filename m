From: Ross Kendall Axe <ross.axe@blueyonder.co.uk>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Wed, 17 Nov 2004 21:29:38 +0000
Message-ID: <419BC2C2.6020100@blueyonder.co.uk>
References: <4197A037.1020307@blueyonder.co.uk> <1100525477.31773.38.camel@moss-spartans.epoch.ncsc.mil> <20041116004122.V14339@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD148A6950C18B5194DE33259"
Cc: Stephen Smalley <sds@epoch.ncsc.mil>, lkml <linux-kernel@vger.kernel.org>,
        jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20041116004122.V14339@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD148A6950C18B5194DE33259
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Chris Wright wrote:
> * Stephen Smalley (sds@epoch.ncsc.mil) wrote:
> 
>>On Sun, 2004-11-14 at 13:13, Ross Kendall Axe wrote:
>>
>>>With CONFIG_SECURITY_NETWORK=y and CONFIG_SECURITY_SELINUX=y, using
>>>SOCK_SEQPACKET unix domain sockets causes an oops in the superfluous(?)
>>>call to security_unix_may_send in sock_dgram_sendmsg. This patch avoids
>>>making this call for SOCK_SEQPACKET sockets.
>>
>>I'd prefer to track down the actual issue in the SELinux code and
>>correct it than just omit the security hook call entirely.  Do you have
>>the Oops output and a trivial test case?  Thanks.
> 

Oops at
http://www.rossaxe.pwp.blueyonder.co.uk/seqpacket-oops/seqpacket-oops.txt
and test case at
http://www.rossaxe.pwp.blueyonder.co.uk/seqpacket-oops/seqpacket-killer.tar.gz
Just run 'seqpacket-crashd & seqpacket-crash' a couple of times.

> 
> Well, there is one simple case that will trigger the Oops.  Send a
> SEQPACKET to a connected but not yet accepted socket.  In this case
> other->sk_socket is still NULL, and SELinux will deref the NULL pointer
> in selinux_socket_may_send() when geting other_isec.  There is already
> a check in unix_stream_connect, which is all that's used for normal unix
> stream sockets.  But the seqpacket socket then uses unix_dgram_sendmsg,
> so triggers the may_send check as well.
> 
> thanks,
> -chris

A possibility that hadn't occurred to me was using sendto to send packets
without connecting. Is this supposed to work? If so, then my patch is
indeed inappropriate. If not, then that needs fixing also.

Ross


--------------enigD148A6950C18B5194DE33259
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBm8LC9bR4xmappRARAqNJAKCs6TwkFyR/ammEiK+B1VsDT0zqDwCfUpi0
OfFWZzLkSFoq9Fn+aQyi338=
=0AW9
-----END PGP SIGNATURE-----

--------------enigD148A6950C18B5194DE33259--
