From: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: net/smc and the RDMA core
Date: Mon, 1 May 2017 17:55:06 +0000
Message-ID: <HE1PR0502MB30048AFD086C4B0D535BFC52D1140@HE1PR0502MB3004.eurprd05.prod.outlook.com>
References: <20170501163311.GA22209@lst.de>
 <1493659776.2665.7.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1493659776.2665.7.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bart, Ursula, Dave,

I am particularly concerned about SMC as address family.
It should not be treated as address family, but rather an additional protoc=
ol similar for socket type SOCK_STREAM.
While doing performance benchmarking last month and while porting few datab=
ase application,

I encountered a major hurdle where user space library heavily depend on AF_=
INET and AF_INET6 family through get_addrinfo and other friend functions.
Adding or treating AF_SMC as AF_INET just doesn't sound right.

Most user space code doesn't care for the protocol field, but do handle dom=
ain field.

I personally believe it's not too late to modify SMC to drop expose AF_SMC =
and have it exposed through new protocol that can be exposed through socket=
() API.

Parav

> -----Original Message-----
> From: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-rdma-
> owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Bart Van Assche
> Sent: Monday, May 1, 2017 12:30 PM
> To: hch-jcswGhMUV9g@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: net/smc and the RDMA core
>=20
> On Mon, 2017-05-01 at 18:33 +0200, Christoph Hellwig wrote:
> > Hi Ursual, hi netdev reviewers,
> >
> > how did the smc protocol manage to get merged without any review on
> > linux-rdma at all?  As the results it seems it's very substandard in
> > terms of RDMA API usage, e.g. it neither uses the proper CQ API nor
> > the RDMA R/W API, and other will probably find additional issues as
> > well.
>=20
> Hello Dave and Ursula,
>=20
> It seems very rude to me to have merged the SMC protocol driver without
> having involved the linux-rdma community. Anyway, I have the following
> questions for Dave and Ursula:
> * Since the Linux kernel is standards based: where can we find the standa=
rd
>   that defines the SMC wire protocol? If this protocol has not been
>   standardized yet: in what file (other than *.[ch]) in the Linux kernel
>   tree has this protocol been documented?
> * What are the differences between the SMC protocol, the SDP protocol and
>   the rsockets protocol? How do existing implementations for these protoc=
ols
>   compare to each other from a performance point of view? If no performan=
ce
>   comparison between these protocols is available, shouldn't the performa=
nce
>   of these protocols have been compared with each other before a review o=
f
>   the SMC driver even started?
> * What are the reasons why the SDP driver was never accepted upstream? Do
>   the arguments why SDP was not accepted upstream also apply to the SMC
>   driver (SDP =3D Sockets Direct Protocol)?
> * Since SMC has to be selected by specifying AF_SMC, how are users expect=
ed
>   to specify whether AF_INET, AF_INET6 or yet another address family shou=
ld
>   be used to set up a connection between SMC endpoints?
> * Is the SMC driver limited to RoCE? Are you aware that the rsockets libr=
ary
>   supports multiple transport layers (RoCE, IB and iWARP)?
> * Since functionality that is similar what the SMC driver provides alread=
y
>   exists in user space (rsockets), why has this functionality been
>   reimplemented as a kernel driver (SMC)?
>=20
> Bart.--
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in =
the body
> of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
