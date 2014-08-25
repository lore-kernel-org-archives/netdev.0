From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] random32: improvements to prandom_bytes
Date: Sun, 24 Aug 2014 18:36:26 -0700 (PDT)
Message-ID: <20140824.183626.1510592099335343622.davem@davemloft.net>
References: <1408806208-11072-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akinobu.mita@gmail.com, LW@KARO-electronics.de,
	netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbaHYBg2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 21:36:28 -0400
In-Reply-To: <1408806208-11072-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 23 Aug 2014 17:03:28 +0200

> This patch addresses a couple of minor items, mostly addesssing
> prandom_bytes(): 1) prandom_bytes{,_state}() should use size_t
> for length arguments, 2) We can use put_unaligned() when filling
> the array instead of open coding it [ perhaps some archs will
> further benefit from their own arch specific implementation when
> GCC cannot make up for it ], 3) Fix a typo, 4) Better use unsigned
> int as type for getting the arch seed, 5) Make use of
> prandom_u32_max() for timer slack.
>=20
> Regarding the change to put_unaligned(), callers of prandom_bytes()
> which internally invoke prandom_bytes_state(), don't bother as
> they expect the array to be filled randomly and don't have any
> control of the internal state what-so-ever (that's also why we
> have periodic reseeding there, etc), so they really don't care.
>=20
> Now for the direct callers of prandom_bytes_state(), which
> are solely located in test cases for MTD devices, that is,
> drivers/mtd/tests/{oobtest.c,pagetest.c,subpagetest.c}:
>=20
> These tests basically fill a test write-vector through
> prandom_bytes_state() with an a-priori defined seed each time
> and write that to a MTD device. Later on, they set up a read-vector
> and read back that blocks from the device. So in the verification
> phase, the write-vector is being re-setup [ so same seed and
> prandom_bytes_state() called ], and then memcmp()'ed against the
> read-vector to check if the data is the same.
>=20
> Akinobu, Lothar and I also tested this patch and it runs through
> the 3 relevant MTD test cases w/o any errors on the nandsim device
> (simulator for MTD devs) for x86_64, ppc64, ARM (i.MX28, i.MX53
> and i.MX6):
>=20
>   # modprobe nandsim first_id_byte=3D0x20 second_id_byte=3D0xac \
>                      third_id_byte=3D0x00 fourth_id_byte=3D0x15
>   # modprobe mtd_oobtest dev=3D0
>   # modprobe mtd_pagetest dev=3D0
>   # modprobe mtd_subpagetest dev=3D0
>=20
> We also don't have any users depending directly on a particular
> result of the PRNG (except the PRNG self-test itself), and that's
> just fine as it e.g. allowed us easily to do things like upgrading
> from taus88 to taus113.
>=20
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Tested-by: Akinobu Mita <akinobu.mita@gmail.com>
> Tested-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Daniel.
