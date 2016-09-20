From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Tue, 20 Sep 2016 20:03:51 +0300
Message-ID: <20160920170351.GT26673@leon.nu>
References: <20160913063806.GP8812@leon.nu>
 <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160913101616.GT8812@leon.nu>
 <BL2PR07MB2306533A710B9EC40F56E8678DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160914130032.GB26069@leon.nu>
 <BL2PR07MB23066BBC4A019365A632E2FA8DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160915043716.GD26069@leon.nu>
 <BL2PR07MB23060C776EDAE92B84FCFB768DF00@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160915054235.GK26069@leon.nu>
 <CY1PR0701MB13376438A5767BC844EA35C290F70@CY1PR0701MB1337.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="mW9eGbZzDIYYWqGs"
Cc: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CY1PR0701MB13376438A5767BC844EA35C290F70-UpKza+2NMNLi6bjPjkn3FE5OhdzP3rhOnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--mW9eGbZzDIYYWqGs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 20, 2016 at 03:04:12PM +0000, Elior, Ariel wrote:
> > From: Leon Romanovsky [mailto:leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org]
> > On Thu, Sep 15, 2016 at 05:11:03AM +0000, Mintz, Yuval wrote:
> > > > As a summary, I didn't see in your responses any real life example where you will
> > > > need global debug level for your driver.
> > >
> > > Not sure what you you're expecting - a list of BZs /private e-mails where
> > > user reproductions were needed?
> > > You're basically ignoring my claims that such are used, instead wanting
> > > "evidence". I'm not going to try and produce any such.
> >
> > I asked an example and not evidence, where "modprobe your_driver
> > debug=1" will be superior to "modprobe your_driver dyndbg==pmf".
> >
> > https://www.kernel.org/doc/Documentation/dynamic-debug-howto.txt
> Hi,
>
> dyndbg vs module param:
> Dynamic debug has two very nice features: dynamic activation/configuration and per line/file/module/format activation. The module param has neither, but it does have a few merits which I am not sure dyndbg has:
> (1)
> It can activate printouts according to *flow*. A lot of thought has been put into associating the right printout in our driver at the right verbosity level with the right "flow tag" (e.g. QEDR_MSG_INIT, QEDR_MSG_QP). The module parameter accepts a bitmask which allows setting any subset of these flows. This means that with the correct values for the parameter I can open only "init" printouts, or only "Memory Region" printouts, even if these cross multiple files / functions and don't share a common format. Presumably, one would claim that we could add the "flow tag" to the format to every printout according to its flow, but that would encumber the printouts, and also doesn't scale well to printouts which belong to multiple flows, where the current approach allows this (QEDR_MSG_SQ | QEDR_
 MSG_RQ).

Dynamic prints are enabled per-print. The best possible granularity
which you can achieve.

> (2)
> As Yuval pointed out, there are users out there which have no trouble loading a driver with a module parameter, at probe or at kernel boot, but would be at a loss in mounting debugfs and dumping a matchspec script into a node there. As kernel developers, educating users is part of what we do, but it comes with a cost.

You are free to add this parameter to your out-of-tree driver. As I said
before to Yuval your module "debug" is equal to "dyndbg". Your users can
use it and is already available in kernel.

> (3)
> debugfs can be compiled out of the kernel in some codesize sensitive environments, or may not exist in an emergency shell or kdump kernel, whereas the module parameter would always be there.
>
> Simply allowing our module parameter mechanism to be dynamically activated is very straightforward - we planned on adding a debugfs node for that anyway. But I would keep the module parameter for the sake of those less capable users and also for when debugfs is not available as detailed in (3) above.

This is an example why we don't want this module parameter, once added it
will be with us forever.

>
> I certainly see the merits of joining an existing infrastructure instead of implementing our own thing, but I would like to know if there are ways of obtaining the merits I listed for our approach via that infrastructure.
>
> Leon, aside of commenting on the above, can you give an example of a driver which in your opinion does a good job of using dyndbg?

All modern drivers in this subsystem are supporting dyndbg out of the
box.

General note, can you please configure your email to wrap lines? It is
very hard to read, follow and respond to lines with >800 symbols in them.

>
> Thanks,
> Ariel
>

--mW9eGbZzDIYYWqGs
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4Wv3AAoJEORje4g2clinSSUQAL6PvnA1iECV7HnJh9Vs5iO4
6bTqgzZoCRxWh8vgu5EE7sfJMC64O4ND65uKM/2IeHa8YmmzYb4juVPBT3T7mPqC
3lXh5UIG8N0/CKVudhQTcVD0pROmBDCbGwtU4sNKJV+8LpUtpDH19G5SShbfiHW7
pc4bTL4tNNu6gmuUEsnpoY9WFa5g75Fp3Wr7yhqME+i1ChTeZ8sECGWxVxm06ram
pwDuFOTskZVXSUnaoC5TxrHHm62HkDyZYN2ucb+UQ2RG6ITRFBWep0dABn6f6TKp
rKu4ctd9dcu3OhLka8D3NOT4yxgOfWCRrQmLNQBmcuQb9Hhwsej5Rw3bSauEZJHe
TBTvhHb7SVYK8j2hWbQ8wbrUNzjWKoVGPbs/0PUKFuGZipkfBcoxe/o+ohG1ox5c
HOBMaLrL3iHUwec0a7wLM/IA13rZ8Z88QhHX+IzkBtUPIuMtGTsKNUR79CtApqRT
R8UA28X+8hSMqtF4OEdDQkifMqS+UGma2/IbM3jB1OqEdDnqfPgTY4HNY3FeQdev
7VV9HcUrSq0Re/hZMx2Voaf4bxbF/s/twTcpXXcK1hKmSBc19fCHgjf/7FVx85+i
Gdw3ldQt0oL8gJGm51n0V6alfu7sXIjWz0q5C18vHDKMFLUPeqjeZqQYjvmd9hWH
mbjrMyn/JjypFVdiiaq9
=kJkA
-----END PGP SIGNATURE-----

--mW9eGbZzDIYYWqGs--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
