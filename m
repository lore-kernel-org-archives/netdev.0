From: Ben Pfaff <blp-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: add NSH support
Date: Wed, 9 Aug 2017 13:53:48 -0700
Message-ID: <20170809205348.GJ6175@ovn.org>
References: <1502168380-106785-1-git-send-email-yi.y.yang@intel.com>
	<20170808162810.1bab3812@griffin>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C391CA@SHSMSX103.ccr.corp.intel.com>
	<20170809024200.GG6175@ovn.org>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D72735682@ESESSMB107.ericsson.se>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C3ADBE@SHSMSX103.ccr.corp.intel.com>
	<20170809180912.GU6175@ovn.org>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C3C14A@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Yang, Yi Y" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <79BBBFE6CB6C9B488C1A45ACD284F51961C3C14A-0J0gbvR4kTggGBtAFL8yw7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2017 at 08:12:36PM +0000, Yang, Yi Y wrote:
> Ben, do you mean we bring two new attributes (OVS_NSH_ATTR_MD1 and
> OVS_NSH_ATTR_MD2) and embed one of them in OVS_ACTION_ATTR_ENCAP_NSH?

Yes.

> Anyway we need to use a struct or something else to transfer those
> metadata between functions, how do you think we can handle this
> without metadata in struct ovs_action_encap_nsh? I mean how we handle
> the arguments for function encap_nsh.

I guess that a pointer to the embedded nlattr with type OVS_NSH_ATTR_MD1
or OVS_NSH_ATTR2 should work OK.

Keep in mind that I'm not a kernel-side maintainer of any kind.  I am
only passing along what I've perceived to be common Netlink protocol
design patterns.

> -----Original Message-----
> From: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] =
On Behalf Of Ben Pfaff
> Sent: Thursday, August 10, 2017 2:09 AM
> To: Yang, Yi Y <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>; dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org; netd=
ev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Zolt=
=E1n Balogh <zoltan.balogh-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
> Subject: Re: [ovs-dev] [PATCH net-next] openvswitch: add NSH support
> =

> On Wed, Aug 09, 2017 at 09:41:51AM +0000, Yang, Yi Y wrote:
> > Hi,  Jan
> > =

> > I have worked out a patch, will send it quickly for Ben. In addition, =

> > I also will send out a patch to change encap_nsh &decap_nsh to =

> > push_nsh and pop_nsh. Per comments from all the people, we all agreed =

> > to do so :-)
> > =

> > diff --git a/datapath/linux/compat/include/linux/openvswitch.h =

> > b/datapath/linux/compat/include/linux/openvswitch.h
> > index bc6c94b..4936c12 100644
> > --- a/datapath/linux/compat/include/linux/openvswitch.h
> > +++ b/datapath/linux/compat/include/linux/openvswitch.h
> > @@ -793,7 +793,7 @@ struct ovs_action_push_eth {
> >         struct ovs_key_ethernet addresses;  };
> > =

> > -#define OVS_ENCAP_NSH_MAX_MD_LEN 16
> > +#define OVS_ENCAP_NSH_MAX_MD_LEN 248
> >  /*
> >   * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
> >   * @flags: NSH header flags.
> > @@ -809,7 +809,7 @@ struct ovs_action_encap_nsh {
> >      uint8_t mdlen;
> >      uint8_t np;
> >      __be32 path_hdr;
> > -    uint8_t metadata[OVS_ENCAP_NSH_MAX_MD_LEN];
> > +    uint8_t metadata[];
> >  };
> =

> This brings the overall format of ovs_action_encap_nsh to:
> =

> struct ovs_action_encap_nsh {
>     uint8_t flags;
>     uint8_t mdtype;
>     uint8_t mdlen;
>     uint8_t np;
>     __be32 path_hdr;
>     uint8_t metadata[];
> };
> =

> This is an unusual format for a Netlink attribute.  More commonly, one wo=
uld put variable-length data into an attribute of its own, which allows tha=
t data to be handled using the regular Netlink means.  Then the mdlen and m=
etadata members could be removed, since they would be part of the additiona=
l attribute, and one might expect the mdtype member to be removed as well s=
ince each type of metadata would be in a different attribute type.
> =

> So, a format closer to what I expect to see in Netlink is something like
> this:
> =

> /**
>  * enum ovs_nsh_attr - Metadata attributes for %OVS_ACTION_ENCAP_NSH acti=
on.
>  *
>  * @OVS_NSH_ATTR_MD1: Contains 16-byte NSH type-1 metadata.
>  * @OVS_NSH_ATTR_MD2: Contains 0- to 255-byte variable-length NSH type-2
>  * metadata. */
> enum ovs_nsh_attr {
>     OVS_NSH_ATTR_MD1,
>     OVS_NSH_ATTR_MD2
> };
> =

> /*
>  * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
>  *
>  * @path_hdr: NSH service path id and service index.
>  * @flags: NSH header flags.
>  * @np: NSH next_protocol: Inner packet type.
>  *
>  * Followed by either %OVS_NSH_ATTR_MD1 or %OVS_NSH_ATTR_MD2 attribute.
>  */
> struct ovs_action_encap_nsh {
>     __be32 path_hdr;
>     uint8_t flags;
>     uint8_t np;
> };
