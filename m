From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC v1 for accelerated IPoIB 05/25] IB/ipoib: Support ipoib
 acceleration options callbacks
Date: Wed, 15 Mar 2017 08:47:51 +0200
Message-ID: <20170315064751.GD2079@mtr-leonro.local>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
 <20170314063538.GB79937@knc-06.sc.intel.com>
 <CAAk-MO8gQ5x-4Ubk1nzPntEWa2ivTK6uXyJ4eC7fmtUCNnOdfA@mail.gmail.com>
 <20170314160021.GD3244@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="yypaS3FvPkEUiGyo"
Cc: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        <saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170314160021.GD3244-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--yypaS3FvPkEUiGyo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 14, 2017 at 10:00:21AM -0600, Jason Gunthorpe wrote:
> On Tue, Mar 14, 2017 at 04:42:55PM +0200, Erez Shitrit wrote:
> > >> +       if (!hca->alloc_rdma_netdev)
> > >> +               dev = ipoib_create_netdev_default(hca, name,
> > >> ipoib_setup_common);
> > >> +       else
> > >> +               dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
> > >> +                                            name, NET_NAME_UNKNOWN,
> > >> +                                            ipoib_setup_common);
> > >> +       if (!dev) {
> > >> +               kfree(priv);
> > >> +               return NULL;
> > >> +       }
> > >
> > >
> > > This will break ipoib on hfi1 as hfi1 will define alloc_rdma_netdev for
> > > OPA_VNIC type. We should probably look for a dedicated return type
> > > (-ENODEV?) to determine of the driver supports specified rdma netdev type.
> > > Or use a ib device attribute to suggest driver support ipoib rdma netdev.
> >
> > sorry, I don't understand that, we are in ipoib driver, so the type is
> > RDMA_NETDEV_IPOIB, if hfi wants to implement it should use the same
> > flag, and to use OPA_VNIC for vnic.
>
> He means it should look like this:
>
>  if (hca->alloc_rdma_netdev)
>      dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
>                                             name, NET_NAME_UNKNOWN,
>                                             ipoib_setup_common);
>
>  if (IS_ERR(dev) && PTR_ERR(dev) != ENOTSUP)
>       goto out;
>
>  dev = ipoib_create_netdev_default(hca, name, ipoib_setup_common);
>  if (IS_ERR(dev))
>       goto out;
>
>  WARN_ON(dev == NULL);
>
>   [...]
>
> out:
>       return PTR_ERR(dev);
>
> And I'm confused why 'ipoib_create_netdev_default' doesn't need the
> same function signature as hca->alloc_rdma_netdev

And now, I'm confused.
In your's proposal, the "dev" will be overwritten, in Erez's proposal,
"dev" will be one of two: defaults or device specific.

>
> Both drivers should implement hca->alloc_rdma_netdev to return ENOTSUP
> if RDMA_NETDEV is not supported.

Did you mean "if RDMA_NETDEV of specific type is not supported"?

Thanks

>
> Jason

--yypaS3FvPkEUiGyo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljI45cACgkQ5GN7iDZy
WKeaSA//fK/AcqTurF3l1v80KZjVxgGl0NrRNbb0IxixBYG2J5QhlJG2ykZikw3I
4vLGpobSjMOYOkWrFOnXaR9E+d8HZ/dwAnaovu/Jon1Zrb8lBQGyp0swtuRAHoiZ
vK+nQHFr3jpyFPt8qrTtDhvWSBDNkAYUsexRkBztmRApnjAn2JhwJOHiQEDl7OpB
SU48EgmeRksfxExpBMrF/Hj0oMpETDKZ85ML8b9NExa5vwZ+mDIWMVHIvPqk3eDg
S7XT9HBWfxc/1Swg8xYvRp14gAAUu9yw85LeY2SAHwttC6pPtbvBe0ARl+IJO9cD
z8bgSd1APpy7WxzjIpAwB7uvd/w2DrggkB813WeTpOT1lJ4BJg+Al+Y3fqmIi5H3
xmUbZwCC+kjw9elEk2/hqjO1He/Mk4qdsqecY0wrlHBJQL3USZ+CI0QompnQ0VxA
YclcL50Bm5xxx5NUKhksrfskZXrKC+4nKs+JspBBRJwpOy3tk4LETu/q/LUUkruZ
ISEjXkFnEid7UkxI69/5zgVG368mrbC8agtUC2bE0UCIWn7uEYHrhymbYeMNeXof
KFj2tZhnmd/cfXaGPo3m0Tyzyaii3DWS4uah37LQYItDZ1lqKUsbyWE2XIpTFzzD
cvJHODI1Z8K4IiKWwUNZxenI3Mxz//yrKnINdalsD7CpHKzLW3U=
=1ImR
-----END PGP SIGNATURE-----

--yypaS3FvPkEUiGyo--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
