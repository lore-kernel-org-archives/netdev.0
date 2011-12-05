From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Mon, 5 Dec 2011 10:44:33 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEFD@saturn3.aculab.com>
References: <20111203122900.GA1617@x4.trippels.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Jerome Glisse" <j.glisse@gmail.com>,
	"Christoph Lameter" <cl@linux.com>,
	"Alex, Shi" <alex.shi@intel.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<dri-devel@lists.freedesktop.org>,
	"Pekka Enberg" <penberg@kernel.org>,
	<linux-mm@kvack.org>,
	"Matt Mackall" <mpm@selenic.com>,
	<tj@kernel.org>,
	"Alex Deucher" <alexander.deucher@amd.com>
To: "Markus Trippelsdorf" <markus@trippelsdorf.de>,
	"Dave Airlie" <airlied@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-class: urn:content-classes:message
In-Reply-To: <20111203122900.GA1617@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

=20
> > If I had to guess it looks like 0 is getting written back to some
> > random page by the GPU maybe, it could be that the GPU is in some
half
> > setup state at boot or on a reboot does it happen from a cold boot
or
> > just warm boot or kexec?
>=20
> Only happened with kexec thus far. Cold boot seems to be fine.

Sounds like the GPU is writing to physical memory from the
old mappings.
This can happen to other devices if they aren't completely
disabled - which may not happen since the kexec case probably
avoids some of the hardware resets that occurr diring a normal
reboot.

I remember an ethernet chip writing into its rx ring/buffer
area following a reboot (and reinstall!) when connected
to a quiet lan.

	David


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
