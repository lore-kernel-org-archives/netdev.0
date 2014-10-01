From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 linux-next] ieee802154: add __init to
 lowpan_frags_sysctl_register
Date: Wed, 1 Oct 2014 06:36:49 +0200 (CEST)
Message-ID: <1016857334.83918.1412138209231.open-xchange@webmail.nmp.skynet.be>
References: <1412109249-7432-1-git-send-email-fabf@skynet.be> <20141001002459.GA1007@omega>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141001002459.GA1007@omega>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 01 October 2014 at 02:25 Alexander Aring <alex.aring@gmail.com> wr=
ote:
>
>
> Hi,
>
> On Tue, Sep 30, 2014 at 10:34:08PM +0200, Fabian Frederick wrote:
> > lowpan_frags_sysctl_register is only called by __init lowpan_net_fr=
ag_init
> > (part of the lowpan module).
> >
> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> > ---
> > This is untested.
> >
> >=C2=A0 net/ieee802154/reassembly.c | 4 ++--
> >=C2=A0 1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembl=
y.c
> > index 32755cb..30ec608 100644
> > --- a/net/ieee802154/reassembly.c
> > +++ b/net/ieee802154/reassembly.c
> > @@ -485,7 +485,7 @@ static void __net_exit
> > lowpan_frags_ns_sysctl_unregister(struct net *net)
> >=C2=A0
> >=C2=A0 static struct ctl_table_header *lowpan_ctl_header;
> >=C2=A0
> > -static int lowpan_frags_sysctl_register(void)
> > +static int __init lowpan_frags_sysctl_register(void)
>
> yes right, but there is more lacks of missing "__init". See below.
>
> >=C2=A0 {
> >=C2=A0 =C2=A0 =C2=A0lowpan_ctl_header =3D register_net_sysctl(&init_=
net,
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0"net/ieee802154/6lowpan",
> > @@ -498,7 +498,7 @@ static void lowpan_frags_sysctl_unregister(void=
)
> >=C2=A0 =C2=A0 =C2=A0unregister_net_sysctl_table(lowpan_ctl_header);
> >=C2=A0 }
> >=C2=A0 #else
> > -static inline int lowpan_frags_ns_sysctl_register(struct net *net)
> > +static inline int __init lowpan_frags_ns_sysctl_register(struct ne=
t *net)
>
> This is wrong, it's callback from "struct pernet_operations lowpan_fr=
ags_ops".
>
> >=C2=A0 {
> >=C2=A0 =C2=A0 =C2=A0return 0;
> >=C2=A0 }
>
>
> Your patch adds "__init" now for two different functions and we have
> two different declarations for these functions, depends if CONFIG_SYS=
CTL is
> enabled.
>
> Now if CONFIG_SYSCTL select we have as lowpan_frags_sysctl_register
> declaration:
>
> static int __init lowpan_frags_sysctl_register(void)
>
> if not:
>
> static inline int lowpan_frags_sysctl_register(void)
>
> Same for lowpan_frags_ns_sysctl_register and vice versa for CONFIG_SY=
SCTL.
>
> Your changes are for two different functions (Don't know if you reali=
zed
> that):

Hi Alexander,

=C2=A0 =C2=A0 I didn't see _ns_ . I'll send the right fix based on wpan=
-next.

Thanks,
=46abian


>
> "lowpan_frags_sysctl_register" and "lowpan_frags_ns_sysctl_register",
> which makes no sense. Also lowpan_frags_ns_sysctl_register isn't call=
ed
> by module init which is wrong.
>
>
> To make "correct" cleanup for this "__init" should be add to the func=
tions,
> for
> both declarations if CONFIG_SYSCTL is set or not:
>
>=C2=A0 - lowpan_net_frag_init
>=C2=A0 - lowpan_frags_sysctl_register
>
>
> I see now it's already applied, David please revert this change. Are =
you
> fine to apply a correct version of this to wpan-next tree, next time?
>
> - Alex
