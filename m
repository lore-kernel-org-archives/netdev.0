From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: wireless management... kernel or user space?
Date: Sun, 20 Jun 2004 09:18:12 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406200918.17829.vkondra@mail.ru>
References: <40D20373.3020406@linux.jf.intel.com> <20040619190441.GE7340@jm.kir.nu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>,
        James Ketrenos <jketreno@linux.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040619190441.GE7340@jm.kir.nu>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Saturday 19 June 2004 22:04, Jouni Malinen wrote:
> > Does anyone have any thoughts on how much logic should be placed into the
> > generic 802.11 frame/management/control handling stack vs. pushing to a
> > user space component?
>
> The ideal location of this logic implementation seems to depend a bit on
> what one is doing..
[skip]
I would add 2 points:

- - we should look carefully for timing requirements. For example, for 
association req/resp, there is no timing requirement in the standard at all; 
for auth sequence with WEP, there is maximum timeout between 2-nd and 3-rd 
frames, but it is not very strong. My point is, if there is flow that require 
timing under 10-20 ms (or even 50), it should be done in kernel.

- - there are lots of meta-information associated with self and wireless peers, 
related to rate scaling, QoS parameters, authentication details etc. I would 
say there is such entity, "peers data base". It may reside in either user 
space, or within the kernel. Logically, management entity and peers data base 
should be on the same side of kernel/user boundary. Rate scaling, if done on 
the host, is very time critical and should be done in kernel. This pushes me 
to the point that it should be in kernel.

BTW, .1X flow is pure data. It is not management one, in terms of 802.11.

Vladimir.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA1Swpqxdj7mhC6o0RAhH3AKCL5CBpytVRs65jl8HHCI2eSbasNACgo+vZ
ta5MHMuyGgvqOtlt6LjiD+s=
=ZZIH
-----END PGP SIGNATURE-----
