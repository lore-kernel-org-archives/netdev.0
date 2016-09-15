From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Thu, 15 Sep 2016 07:37:16 +0300
Message-ID: <20160915043716.GD26069@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
 <20160913063806.GP8812@leon.nu>
 <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160913101616.GT8812@leon.nu>
 <BL2PR07MB2306533A710B9EC40F56E8678DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160914130032.GB26069@leon.nu>
 <BL2PR07MB23066BBC4A019365A632E2FA8DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="48TaNjbzBVislYPb"
Cc: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23066BBC4A019365A632E2FA8DF10-I6Fv6QFlT9L2NWYWB7JgfuFPX92sqiQdvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--48TaNjbzBVislYPb
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 14, 2016 at 06:25:38PM +0000, Mintz, Yuval wrote:
> > > > > >> >> +uint debug;
> > > > > >> >> +module_param(debug, uint, 0);
> > > > > > >>> +MODULE_PARM_DESC(debug, "Default debug msglevel");
> > > > > >>
> > > > > >> >Why are you adding this as a module parameter?
> > > > > >>
> > > > > >>=A0 I believe this is mostly to follow same line as qede which =
also defines
> > > > > > > 'debug' module parameter for allowing easy user control of de=
bug
> > > > > > > prints [& specifically for probe prints, which can't be contr=
olled
> > > > > > > otherwise].
> > > > >
> > > > > > Can you give us an example where dynamic debug and tracing infr=
astructures
> > > > > > are not enough?
> > > > >
> > > > > > AFAIK, most of these debug module parameters are legacy copy/pa=
ste
> > > > > > code which is useless in real life scenarios.
> > > > >
> > > > > Define 'enough'; Using dynamic debug you can provide all the nece=
ssary
> > > > > information and at an even better granularity that's achieved by =
suggested
> > >  > > infrastructure,=A0 but is harder for an end-user to use. Same go=
es for tracing.
> > > > >
> > > > > The 'debug' option provides an easy grouping for prints related t=
o a specific
> > > > > area in the driver.
> > > >
> > > > It is hard to agree with you that user which knows how-to load modu=
les
> > > > with parameters won't success to enable debug prints.
> > >
> > > I think you're giving too much credit to the end-user. :-D
> > >
> > > > In addition, global increase in debug level for whole driver will c=
reate
> > > > printk storm in dmesg and give nothing to debuggability.
> > >
> > > So basically, what you're claiming is that ethtool 'msglvl' setting f=
or devices
> > > is completely obselete. While this *might* be true, we use it extensi=
vely
> > > in our qede and qed drivers; The debug module parameter merely provid=
es
> > > a manner of setting the debug value prior to initial probe for all in=
terfaces.
> > > qedr follows the same practice.
>
> > Thanks for this excellent example. Ethtool 'msglvl' adds this
> > dynamically, while your DEBUG argument works for loading module
> > only.
>
> > If you want dynamic prints, you have two options:
> > 1. Add support of ethtool to whole RDMA stack.
> > 2. Use dynamic tracing infrastructure.
>
> > Which option do you prefer?
> Option 3 - continuing this discussion. :-)

Sorry,
I was under impression that you want this driver to be merged, but it
looks like It was incorrect assumption. Let's continue discussion.

>
> Perhaps I misread your intentions - I thought that by dynamic debug
> you meant that all debug in RDMA should be pr_debug() based, and
> therefore my objection regarding the ease with which users can
> configure it.

It is not for all RDMA, but in your proposed driver. You are adding this
"debug" module argument to your module.

> If all you meant was 'dynamically set' as opposed to 'statically set'
> then I agree that having that sort of configurability is preferable
> [Even though end-user would still probably prefer a module
> parameter for reproductions; As the name implies, 'debug' isn't
> meant to be used in other situations].

We are not adding code just for fun, but for a real reason, and
especially interfaces which will be visible to user.

The overall expectation from the driver's authors that they are
submitting driver which doesn't have bringup issues. For real
life scenarios, where the bugs will be reveled after some time of
usage, this global debug is useless.

>
> The other thing to consider are the probe-time prints.
> Problem is, you wouldn't have a control node between probe
> and until after the probing would be over, so it would be a bit
> hard to configure that.
> You can always think of some generic method of fixing that as well
> [sysfs node for the entire system for probe-time prints, perhaps?]

/sys/kernel/debug/tracing
/sys/kernel/debug/dynamic_debug

>
> Do notice you would be harming user-experience of reproductions
> though - as it would have to follow different mechanisms to open
> debug prints of various qed* components.

I don't understand this point at all. Do you think that it is normal to
ask user to debug your driver? Is this called "user-experience"?

And regarding the second point, the old code is not an excuse to
copy/paste bad practices.

As a summary, I didn't see in your responses any real life example where
you will need global debug level for your driver.

Thanks

--48TaNjbzBVislYPb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2iV8AAoJEORje4g2clineSgP/0sOh2SscHUeajfXPjwMo8DF
pX7crPRmvRtu6jYAgp0w6/GfQG7QyAMK9GJfL3tNiyGbNpIV6qp8gwTQhTf0TDZH
Idq2DUcaCNVWykcGh5zYCMrIoGXI0bhR4ttkUBz186TxmQXYAh2za4F7aCztwAli
ejiYwxQoOTop0UZsVYTquQavmGRQM2AqF/w8pBUKe0Pth/GyP4gYN34EWzS+wxS4
B112254xykn7qt/mpNfhEvEhdjEQHXA9zMHpv8wVfmcMVOHV/PltwoLh+h+tkf+q
O4Upq0k+ep6h9N/YnInfgo8oyN3XhaLMUz17a+4wsF29Pb65Cgp5GWxEdOhaP1Pl
0CRTYFHihu5q5AA/0zkisOXl42grCrwuS0bp4B2BTo87YAmdDP1q2F83MnnmjX2B
x/XxiuoRVk1zlKKTmOM1P/oXOrYAU5k5qf3nxOrMwqQpGUUUr1sv/+quRHVsg0yj
KEENOn+o7MJNGXGGGbfU3jo7wCg+hqtw3XCuuS8hfDDKbfZc0sRe6TlirMC8uIJL
UMsGbVcg4x8CafgqxdQ1jFS4BGXrjkm/T4/pl51faAoBiZQDaf6qKOceybHlvCGT
alTXO2AbgDShxGhMe2R4OJmJt+HiuONB/rSvChrIkmYXqjGF4EB1DdldyrHCZhC/
zZvO3SIKOL/z/g+bkY/Z
=ZiPE
-----END PGP SIGNATURE-----

--48TaNjbzBVislYPb--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
