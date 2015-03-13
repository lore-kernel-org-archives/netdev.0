From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Fri, 13 Mar 2015 15:38:17 +1100
Message-ID: <20150313153817.34510752@canb.auug.org.au>
References: <20150313131543.7c050492@canb.auug.org.au>
	<20150312.232426.1464986797003264151.davem@davemloft.net>
	<20150313035609.GO29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/j=F8LTLCd9FBfQ97lxtUrQ5"; protocol="application/pgp-signature"
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, hch@lst.de, ying.xue@windriver.com,
	Felipe Balbi <balbi@ti.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-usb@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:52347 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbbCMEiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 00:38:24 -0400
In-Reply-To: <20150313035609.GO29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/j=F8LTLCd9FBfQ97lxtUrQ5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Al,

On Fri, 13 Mar 2015 03:56:09 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:
>
> On Thu, Mar 12, 2015 at 11:24:26PM -0400, David Miller wrote:
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Fri, 13 Mar 2015 13:15:43 +1100
> >=20
> > > Today's linux-next merge of the net-next tree got a conflict in
> > > net/socket.c between commits 005139a14660 ("fs: remove ki_nbytes") and
> > > e9eab93cc2dc ("fs: don't allow to complete sync iocbs through
> > > aio_complete") from the vfs tree and commit 1b784140474e ("net: Remove
> > > iocb argument from sendmsg and recvmsg") from the net-next tree.
> > >=20
> > > I fixed it up (mainly using the net-next version - see below) and can
> > > carry the fix as necessary (no action is required).
> >=20
> > Al, how do you want to resolve this?
>=20
> Hmm...  I could backmerge 1b784140474e4fc94281a49e96c67d29df0efbde into
> vfs.git#for-next, of course, but you've got quite a pile of stuff in front
> of it...  FWIW, the conflict resolution proposed by Stephen is correct;
> the question is what should go into which tree.
>=20
> Actually, prereqs of the commit in question on vfs.git side are mostly
> -stable fodder; all it really needs is vfs.git#gadget and I was planning
> to send that to Linus - fixes for leaks and use-after-free in gadgetfs
> that had been there since forever, plus fixes for regression since 3.18
> (->f_op flipping that had always been fishy and outright broke when we
> started to FMODE_CAN_READ/FMODE_CAN_WRITE).  USB folks seem to be OK
> with it.  Christoph's patch isn't a regression fix, but seeing that it's
> (a) trivial and (b) ends up causing merge headache...  Maybe it would
> make sense to pull it into mainline and resolve the conflict on backmerge
> from mainline to net-next.  Linus?  I've pushed that (gadget + ki_nbytes)
> into vfs.git#for-linus-2; would you be OK with pulling that?
>=20
> It's on
> git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-linus-2
>=20
> Shortlog:
> Al Viro (8):
>       new helper: dup_iter()
>       move iov_iter.c from mm/ to lib/
>       gadget/function/f_fs.c: close leaks
>       gadget/function/f_fs.c: use put iov_iter into io_data
>       gadget/function/f_fs.c: switch to ->{read,write}_iter()
>       gadgetfs: use-after-free in ->aio_read()
>       gadget: switch ep_io_operations to ->read_iter/->write_iter
>       gadgetfs: get rid of flipping ->f_op in ep_config()
>=20
> Alan Stern (1):
>       gadgetfs: really get rid of switching ->f_op
>=20
> Christoph Hellwig (1):
>       fs: remove ki_nbytes

There is also a conflict with e9eab93cc2dc ("fs: don't allow to
complete sync iocbs through aio_complete"), though it doesn't show up
in the resolution since I I just used the next-next tree bits.  So a
common branch containing that as well could be merged into both trees.

But none of this is really that complex, maybe worth a hint to Linus
during the merge window.  Unless there is more planned for that file?
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/j=F8LTLCd9FBfQ97lxtUrQ5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVAmm+AAoJEMDTa8Ir7ZwV9WgP/jXQ00AuufGrqCILDvSXPBl5
kPPZncbebYV4pTrg5vToonsSyRuw2dueyDVFoA6AnyvfVlrcc1vk35gCNTVVdBew
v6q6CQcarB76guyS6z8/f2EMFpNHpk8VELt+lnUfhrXsYmlVHmup8D74zzJgeB8h
6Jv3hOt2N5uH1VJQa0OmaJ4krZOAwywN12e0pJu/PjE4u+L6oBHame00QvU9Y72m
wdZnjErOiFA0Dzq7X0vGBQ9QPwb+ZsewsNcE19uIu0sR7nWSuVjgAaVMyL1kl6xZ
hMh++IlcGO4KqzzgSrdEa4tzaqAO7+dnWBSaKVagF6BBoIL5OQQAdYJakh4ceRfE
81wuepuMyiSi/E+3Htm9GX5rWIv+IQtEJhPlMHDVTVN4qBROY8hPjJmw7pY8Sadd
w0lnY8kn3csogQATxVbtljXh8pqicAbzln7U5fSwrEG+64eo33gNDfPMYCrowK6t
p1hhK2Bi0hsd1kH2smPmZkc2tg8kmHAQYQosfUPSd7Enz7cKb2+PZ5CUCnbPmpTW
3I8BddAIz21562SQ0WuZHeofwQ7QsJuwxE4iRpI5hLFLaIbNEbw1dHEbqLEc6SGC
NqPBSa1BWwb4RTqxdwuRP8N3v9hV6sKmSiIGtg13IEGV92+efZ19+KKXWklEkeK/
vVDkt5i2GTnyjFlk0jy/
=Sagr
-----END PGP SIGNATURE-----

--Sig_/j=F8LTLCd9FBfQ97lxtUrQ5--
