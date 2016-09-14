From: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Wed, 14 Sep 2016 18:25:38 +0000
Message-ID: <BL2PR07MB23066BBC4A019365A632E2FA8DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
 <20160913063806.GP8812@leon.nu>
 <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160913101616.GT8812@leon.nu>
 <BL2PR07MB2306533A710B9EC40F56E8678DF10@BL2PR07MB2306.namprd07.prod.outlook.com>,<20160914130032.GB26069@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "Ram Amrani" <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160914130032.GB26069-2ukJVAZIZ/Y@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > > >> >> +uint debug;
> > > > >> >> +module_param(debug, uint, 0);
> > > > > >>> +MODULE_PARM_DESC(debug, "Default debug msglevel");
> > > > >>
> > > > >> >Why are you adding this as a module parameter?
> > > > >>
> > > > >>=A0 I believe this is mostly to follow same line as qede which al=
so defines
> > > > > > 'debug' module parameter for allowing easy user control of debu=
g
> > > > > > prints [& specifically for probe prints, which can't be control=
led
> > > > > > otherwise].
> > > >
> > > > > Can you give us an example where dynamic debug and tracing infras=
tructures
> > > > > are not enough?
> > > >
> > > > > AFAIK, most of these debug module parameters are legacy copy/past=
e
> > > > > code which is useless in real life scenarios.
> > > >
> > > > Define 'enough'; Using dynamic debug you can provide all the necess=
ary
> > > > information and at an even better granularity that's achieved by su=
ggested
> >  > > infrastructure,=A0 but is harder for an end-user to use. Same goes=
 for tracing.
> > > >
> > > > The 'debug' option provides an easy grouping for prints related to =
a specific
> > > > area in the driver.
> > >
> > > It is hard to agree with you that user which knows how-to load module=
s
> > > with parameters won't success to enable debug prints.
> >
> > I think you're giving too much credit to the end-user. :-D
> >
> > > In addition, global increase in debug level for whole driver will cre=
ate
> > > printk storm in dmesg and give nothing to debuggability.
> >
> > So basically, what you're claiming is that ethtool 'msglvl' setting for=
 devices
> > is completely obselete. While this *might* be true, we use it extensive=
ly
> > in our qede and qed drivers; The debug module parameter merely provides
> > a manner of setting the debug value prior to initial probe for all inte=
rfaces.
> > qedr follows the same practice.

> Thanks for this excellent example. Ethtool 'msglvl' adds this
> dynamically, while your DEBUG argument works for loading module
> only.

> If you want dynamic prints, you have two options:
> 1. Add support of ethtool to whole RDMA stack.
> 2. Use dynamic tracing infrastructure.

> Which option do you prefer?
Option 3 - continuing this discussion. :-)

Perhaps I misread your intentions - I thought that by dynamic debug
you meant that all debug in RDMA should be pr_debug() based, and
therefore my objection regarding the ease with which users can
configure it.=20
If all you meant was 'dynamically set' as opposed to 'statically set'
then I agree that having that sort of configurability is preferable
[Even though end-user would still probably prefer a module
parameter for reproductions; As the name implies, 'debug' isn't
meant to be used in other situations].

The other thing to consider are the probe-time prints.
Problem is, you wouldn't have a control node between probe=20
and until after the probing would be over, so it would be a bit
hard to configure that.
You can always think of some generic method of fixing that as well
[sysfs node for the entire system for probe-time prints, perhaps?]

Do notice you would be harming user-experience of reproductions
though - as it would have to follow different mechanisms to open
debug prints of various qed* components.=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
