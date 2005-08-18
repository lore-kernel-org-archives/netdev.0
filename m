From: Coywolf Qi Hunt <coywolf@gmail.com>
Subject: Re: [PATCH] struct file cleanup : the very large file_ra_state is now allocated only on demand.
Date: Thu, 18 Aug 2005 09:39:16 +0800
Message-ID: <2cd57c90050817183942b217fa@mail.gmail.com>
References: <20050810164655.GB4162@linux.intel.com>
	 <20050810.135306.79296985.davem@davemloft.net>
	 <20050810211737.GA21581@linux.intel.com>
	 <430391F1.9080900@cosmosbay.com>
	 <20050817211829.GK27628@wotan.suse.de>
	 <4303AEC4.3060901@cosmosbay.com> <20050817215357.GU3996@wotan.suse.de>
	 <4303D90E.2030103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <ak@suse.de>, Benjamin LaHaise <bcrl@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932076AbVHRBjS@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4303D90E.2030103@cosmosbay.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/18/05, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Andi Kleen a =E9crit :
>=20
> >
> >>(because of the insane struct file_ra_state f_ra. I wish this struc=
ture
> >>were dynamically allocated only for files that really use it)
> >
> >
> > How about you submit a patch for that instead?
> >
> > -Andi
>=20
> OK, could you please comment this patch ?
>=20
> The problem of dynamically allocating the readahead state data is tha=
t the allocation can fail and should not be fatal.
> I made some choices that might be not good.
>=20
> I also chose not to align "file_ra" slab on SLAB_HWCACHE_ALIGN becaus=
e the object size is 10*sizeof(long), so alignment would loose
> 6*sizeof(long) bytes for each object.
>=20
>=20
> [PATCH]
>=20
> * struct file cleanup : the very large file_ra_state is now allocated=
 only on demand, using a dedicated "file_ra" slab.
>         64bits machines handling lot of sockets can save about 72 byt=
es per file.
> * private_data : The field is moved close to f_count and f_op fields =
to speedup sockfd_lookups

Why not keep the comment or fix it?

--=20
Coywolf Qi Hunt
http://ahbl.org/~coywolf/
