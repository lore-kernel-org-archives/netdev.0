From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Mon, 12 Jan 2015 22:59:44 +0000
Message-ID: <20150112225944.GC11857@casper.infradead.org>
References: <cover.1421064100.git.tgraf@suug.ch>
 <014606bb741d017675f7728a0bccc4cbed42af4b.1421064100.git.tgraf@suug.ch>
 <CAEP_g=8TqGnftZa_scKODa2ra7gsV6ov_5J+Lbfq+4bFDZjiBw@mail.gmail.com>
 <20150112224749.GB11857@casper.infradead.org>
 <CAEP_g=-85jmr3b6J0xfy661G_Ffh2LkOH=FazhfhVBwSjwHQNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48123 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbbALW7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 17:59:45 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-85jmr3b6J0xfy661G_Ffh2LkOH=FazhfhVBwSjwHQNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 02:50pm, Jesse Gross wrote:
> On Mon, Jan 12, 2015 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 01/12/15 at 11:23am, Jesse Gross wrote:
> >> On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> >> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> >> > index 4d52aa9..b148739 100644
> >> > --- a/drivers/net/vxlan.c
> >> > +++ b/drivers/net/vxlan.c
> >> > @@ -568,7 +569,8 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
> >> >                         continue;
> >> >
> >> >                 vh2 = (struct vxlanhdr *)(p->data + off_vx);
> >> > -               if (vh->vx_vni != vh2->vx_vni) {
> >> > +               if (vh->vx_flags != vh2->vx_flags ||
> >> > +                   vh->vx_vni != vh2->vx_vni) {
> >>
> >> It's probably better to do a memcmp over the entire header. There's no
> >> guarantee that new fields will be entirely represented by flags.
> >
> > vx_flags covers the entire first 32 bit of vxlanhdr so it's
> > equivalent to a memcmp() already. I can change it to memcmp() if
> > you think that's more readable.
> 
> I was actually referring to the reserved 8 bit chunk after the VNI.
> This could potentially be used for something in the future.

Shouldn't that be covered by vh->vx_vni != vh2->vx_vni? I may
still misunderstand, sorry.
