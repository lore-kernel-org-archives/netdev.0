From: Paul Burton <paul.burton@imgtec.com>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 22:23:12 -0700
Message-ID: <2162402.U1AhUEO55C@np-p-burton>
References: <1752163.uYYNevmZpH@np-p-burton> <2520219.WSsBr6LeCR@np-p-burton> <20170926.215321.424825014223425519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4293004.Fa26SZIz8x";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: <matt.redfearn@imgtec.com>, <netdev@vger.kernel.org>,
        <alexandre.torgue@st.com>, <peppe.cavallaro@st.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <james.hogan@imgtec.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926.215321.424825014223425519.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4293004.Fa26SZIz8x
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi David,

On Tuesday, 26 September 2017 21:53:21 PDT David Miller wrote:
> From: Paul Burton <paul.burton@imgtec.com>
> Date: Tue, 26 Sep 2017 21:30:56 -0700
> 
> > Nobody said that you are required to do anything, I suggested that
> > it would be beneficial if you were to suggest a change to the
> > documented DMA API such that it allows your usage where it currently
> > does not.
> 
> Documentation is often wrong and it is here.  What 200+ drivers
> actually do and depend upon trumps a simple text document.

Agreed - but if the documented API is wrong then it should change.

> The requirement is that the memory remains quiescent on the cpu side
> while the device messes with it.  And that this quiescence requirement
> may or may not be on a cache line basis.
> 
> There is absolutely no requirement that the buffers themselves are
> cache line aligned.
> 
> In fact, receive buffers for networking are intentionally 2-byte
> aligned in order for the ipv4 headers to be naturally 32-bit aligned.
> 
> Cache line aligning receive buffers will actually make some
> architectures trap because of the bad alignment.
> 
> So see, this cache line alignment requirement is pure madness from
> just about any perspective whatsoever.

Thank you - that's more constructive.

I understand that the network code doesn't suffer from a problem with using 
non-cacheline-aligned buffers, because you guarantee that the CPU will not be 
writing to anything on either side of the memory mapped for DMA up to at least 
a cache line boundary. That is all well & good (though still, I think that 
ought to be documented somewhere even if just by a comment somewhere in linux/
sk_buff.h).

There is still a problem though in other cases which do not provide such a 
guarantee - for example the MMC issue I pointed out previously - which it 
would be useful to be able to catch rather than allowing silent memory 
corruption which can be difficult to track down. Whilst the particular case of 
mapping a struct sk_buff's data for DMA might not trigger this issue the issue 
does still exist in other cases for which aligning data to a cache line 
boundary is not always "pure madness".

So whilst it sounds like you'd happily just change or remove the paragraph 
about cache-line alignment in Documentation/DMA-API.txt, and I agree that 
would be a good start, I wonder whether we could do something better. One 
option might be for the warning in the MIPS DMA code to be predicated on one 
of the cache lines only partially covered by a DMA mapping actually being 
dirty - though this would probably be a more expensive check than we'd want in 
the general case so might have to be conditional upon some new debug entry in 
Kconfig. I'll give this some thought.

Thanks,
    Paul
--nextPart4293004.Fa26SZIz8x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEELIGR03D5+Fg+69wPgiDZ+mk8HGUFAlnLNcAACgkQgiDZ+mk8
HGVTXQ//Zou+GNwcRi8mdnQwK8Nt8cnWhDQ9EcsouWFeXgL5CJ1KqORAXgR93xNC
u4T1X6G5+8s1ajEsjOhn5o4tvrQbh01rgNmgx9C10bzhcvLL8sEr/KLcqbHk4s8V
2Bg4ot4SRTq5QS8gPHlTlNX0CZZzURnD1XA2cCX67VhkHn9ui9dLvcIosVD+2sxZ
IoQn9P7kK2sQrgcvKdfjym3FqayZQ18T916hyWN7Pj0Iz5CgOAGqRD0mkdYA8Pi7
ZkbBnizt84+ulU2meHddrxCoLAE0ymS1kEpvv0xz+OF1gVWv11ea9GewlPTLoPb2
qyLLtrPaRWuoQTHSvjx7g7VGC4jaZ8rr6QVmZDE7yqkQN5oLHm/svGqn6wcC6zb1
P+83qF1uQxDkjioDSHSMcg+/6qdNWdY9EfjYCSU0s8l2kGMAPrbmNKOkcDsENOf+
YHlu+CO+7hZGGtEFANF1NhIl4j/Q+dd5sFuElB01Ll8tEIM7xc4geh0wbABX4Iu3
0Xp1raNmMYH9GHJXu8hbH4oHE+i0YPfZAffrE25vb6g90NXSx8YLniyD3CY5bK/S
U43WzRZh/+zgPcrrWjkHGAx/lrvHQ0JKbT7Fq8LNkB1LsrJ0BugSHsO+TqEYCdR0
gnH2ILZDKQAB6BVsvg5RtxY0phI7vSDvbJFBe2scy8Uforjb934=
=9ahm
-----END PGP SIGNATURE-----

--nextPart4293004.Fa26SZIz8x--
