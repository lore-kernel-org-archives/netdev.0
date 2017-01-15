From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Sun, 15 Jan 2017 09:20:18 +0200
Message-ID: <20170115072018.GZ20392@mtr-leonro.local>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
 <20170113.121407.448230751444957957.davem@davemloft.net>
 <20170113202932.GS20392@mtr-leonro.local>
 <CALx6S37hb78RJ8tCtsCsX2fg6e-D+naNpSQo6T2AyWMd0U74sQ@mail.gmail.com>
 <CALzJLG_RsvgszVxGZ7+VgYjET9w=XTjq36Z72diOQFNJWz9tQw@mail.gmail.com>
 <CALx6S37FHv3d0_hsXd63m37CEgT4N8myjUey29iDo1DRR=T9tQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="js+/jT5SQQin5+Fm"
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALx6S37FHv3d0_hsXd63m37CEgT4N8myjUey29iDo1DRR=T9tQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--js+/jT5SQQin5+Fm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jan 14, 2017 at 09:37:20AM -0800, Tom Herbert wrote:
> On Fri, Jan 13, 2017 at 2:45 PM, Saeed Mahameed
> <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
> > On Sat, Jan 14, 2017 at 12:06 AM, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
> >> On Fri, Jan 13, 2017 at 12:29 PM, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> >>> On Fri, Jan 13, 2017 at 12:14:07PM -0500, David Miller wrote:
> >>>> From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >>>> Date: Thu, 12 Jan 2017 19:22:34 +0200
> >>>>
> >>>> > This pull request includes one patch from Leon, this patch as described
> >>>> > below will change the driver directory structure and layout for better,
> >>>> > logical and modular driver files separation.
> >>>> >
> >>>> > This change is important to both rdma and net maintainers in order to
> >>>> > have smoother management of driver patches for different mlx5 sub modules
> >>>> > and smoother rdma-next vs. net-next features submissions.
> >>>> >
> >>>> > Please find more info below -in the tag commit message-,
> >>>> > review and let us know if there's any problem.
> >>>> >
> >>>> > This change doesn't introduce any conflicts with the current mlx5
> >>>> > fixes and cleanups posted on 2017-01-10 to net branch, and merge tests
> >>>> > worked flawlessly with no issues.
> >>>> >
> >>>> > This is the last pull request meant for both rdma-next and net-next.
> >>>> > Once pulled, this will be the base shared code for both trees.
> >>>>
> >>>> This is pretty crazy, it will make all bug fix backporting to -stable
> >>>> a complete nightmare for myself, Doug, various distribution maintainers
> >>>> and many other people who quietly have to maintain their own trees and
> >>>> do backporting.
> >>>
> >>> Hi Dave,
> >>>
> >>> I understand your worries, but our case is similar to various other
> >>> drivers, for example hfi1 which was in staging for years while
> >>> supported in RedHat and moved from there to IB. The Chelsio drivers did
> >>> similar reorg in 2016 (drivers/net/ethernet/chelsio/libcxgb) while their
> >>> drivers were in the tree for long time before.
> >>>
> >>> Additionally, Doug doesn't need to maintain -stable queue and it is done
> >>> by relevant submaintainers who are adding stable tags by themselves. In
> >>> the IB case, the burden will continue to be on me and not on Doug.
> >>>
> >> Recently I had to backport the mlx5 driver from 4.9 to 4.6 in order to
> >> get support for XDP. The biggest issue I faced was the lack of
> >> modularity in the many driver features that are now supported. The
> >> problem with backporting these new features is the spider web of
> >> dependencies that they bring in from the rest of the kernel. I ended
> >> up taking out en_rep, vxlan, en_tc, eswitch, and dcbnl. The result was
> >> ~340 patches which is still a lot but at least this was constrained to
> >> patches in the mlx5 directories and are relevant to what we want to
> >> do.

We had that complexity in mind. This pull request is our initial step
to simplify backporters' work (e.g. rename of en_XXX.c to be XXX.c is
the same as en/XXX.c for the backports).

We are aware of IB backports which required EN part of driver which
had all net dependencies mentioned above and IMHO it is wrong.

Our plan is:
1. Reorg/rename files.
2. Separate en and IB from shared code, to allow parallel work.
3. Reduce en and IB dependencies, to simplify backporting.

It is really awkward to move to item 2 and 3 before we cleaned the desk.
That rename patch provided to all backporters an easy way to bring new
features into the driver.

> >>
> >> In lieu of restructuring the directories, I would much rather see more
> >> config options so that we can build drivers that don't unnecessarily
> >> complicate our lives with features we don't use. This is not just true
> >> for Mellanox, but I would say it would be true of any driver that
> >> someone is trying to deploy and maintain at large scale.

Different maintainers have a different view on the subject and not everyone
is ready to accept new drivers config options.


> >>
> >
> > I think we should have both, if the restructuring made right,
> > new whole features (e.g eswitch and eswitch offlaods or any independent module),
> > can sit in their own directory and keep their own logic concentrated
> > in one place, and only touch the
> > main driver code with simple entry points in the main flow,  this way
> > you can simply compile their whole directories
> > out with a config flag directly from the Makefile.
> >
> That would be nice, but that is not what your new layout gives us yet.
> The starting point for this structure should be to discern what the
> minimum set of files is to build a functional and good performance
> driver with the basic functionality including only the most common
> offloads. These I would think constitute the core files for the driver
> and hence make sense to be in the "core" directory. Personally I would
> drop the en_ file prefix and not make an en directory, we're already
> in the ethernet driver part of the tree so I don't know what this name
> is supposed to convey. For reference I gave you this list of
> components I disabled to do the backport, some we're not split out in
> your directory layout. A good example is the VXLAN offload support,
> the changes in that area we're mostly due to Alexander's patch set to
> redo the interface for these accelerations-- so to back port driver
> from 4.9 to 4.6 I would need to pull those in and whatever else those
> depend on. It was way easier to just ifdef out the relevant calls and
> not compile the vxlan files to do the backport.

We would love to move into that direction, but right now that core
directory serves our IB driver too. Once we separate them, your proposal
will be possible to implement.

>
> Tom
>
> >> Btw, we did hit one issue in the backport. We started to get rx csum
> >> faults (checksum complete value indicates TCP checksum is bad, but
> >> host computation says checksum is good). I ran against 4.9 upstream
> >> kernel and do see these, however don't see them in 4.10. I haven't
> >> bisected yet. Is this a known issue?
> >>
> >
> > Not to me, I don't recall any csum related fixes or feature submitted
> > lately to mlx5,
> > Maybe something changed in the stack ?
> >
> > what configuration are you running ? what traffic ?
> >
> >> Thanks,
> >> Tom
> >>
> >>>>
> >>>> I really don't think you can justify this rearrangement based upon the
> >>>> consequences and how much activity happens in this driver.
> >>>>
> >>>> You should have thought long and hard about the layout a long time ago
> >>>> rather than after the driver has been in the tree for many years.
> >>>>
> >>>> Sorry.
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> >> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--js+/jT5SQQin5+Fm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh7IrIACgkQ5GN7iDZy
WKeqqRAAyRVtjDRzNiC03J2y/pLbzjT4f32Gktx3mR7JUlG9a7ByZALaty8hahif
JWuO1ZRMs/ADZbdoE2aeMRVua6hp/ZcFyBTuFFEgsfApwvh1+uUTMvh1DRnhyHjT
IbCFzLXykCamvZtQU5Jc6A0W5XrddbI91Fld//qaLQl3VEGPumavUA34duu6bflQ
cZMzw63CvSr4jv7+g2cr6gT5lyvnRruzqNC9eeifthCAYYGSgkUSZ0GYud79f+3c
zJCxfZCm6dRVco96WjOSziSbxU50M2MMm5n04IswMtMl5IXeOrD9Cv8Ly1lF0AeB
GoR8ejdQRO5CT4C9u7TXGeaODB/fM5qEjJm7mRsOzxS2vm2qJy6vKjO5UioqParY
G7B/zf5Kb0N+qBX6A+/n24Bx8T2BJHtOX4iwIKrA0IEXwn17/cVIFyY02PaCWu3p
QxeJNIrwIxM7vYAw7vvvik+66GAgXh7zbnVrLc6ESqHcdU/wLHIQml+T/yPrPtea
6Q82eIwdpfPtNcR1uNy3yA268aTuz+F1luNjM7jUuoLcAk85lL76148Hb7+0g3fP
RgQDr9gF0Kq1loW4NzSins9G24rVCoU7EuEyOoexux2SIw3u7Gz2/hBmbMs76vo7
xrttZ9dJN48y9mZC5KiV/xgfJ0haXsWJaoJ6rbt2D+wH23Nh8oY=
=Ubo7
-----END PGP SIGNATURE-----

--js+/jT5SQQin5+Fm--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
