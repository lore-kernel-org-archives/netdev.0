From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Mon, 6 Apr 2015 14:44:09 -0400
Message-ID: <20150406184409.GC2866@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
 <CAEP_g=9PbDO4qK-GaGosBAq1S5C5uWNR4-JN8=i158oYJUN4Bw@mail.gmail.com>
 <20150404010142.GA1063@electric-eye.fr.zoreil.com>
 <CAEP_g=-qyy6PNEqKQWVaw5Wf9MvcUk-Hx5Mrk7jaTEihK3Tqzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53866 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbDFSpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 14:45:20 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=-qyy6PNEqKQWVaw5Wf9MvcUk-Hx5Mrk7jaTEihK3Tqzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 06, 2015 at 11:06:02AM -0700, Jesse Gross wrote:
> On Fri, Apr 3, 2015 at 6:01 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Jesse Gross <jesse@nicira.com> :
> > [...]
> >> > diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> >> > new file mode 100644
> >> > index 000000000000..fe8895487fc2
> >> > --- /dev/null
> >> > +++ b/drivers/net/geneve.c
> >> > +/* geneve receive/decap routine */
> >> > +static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
> >> > +{
> >> > +       struct genevehdr *gnvh = geneve_hdr(skb);
> >> > +       struct geneve_dev *geneve;
> >> > +       struct pcpu_sw_netstats *stats;
> >> > +
> >> > +       geneve = gs->rcv_data;
> >> > +
> >> > +       /* Does the VNI match the device? */
> >> > +       if (memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)))
> >> > +               goto drop;
> >>
> >> Since Geneve packets can carry options and this doesn't currently
> >> support any, I think we need to at least check the 'C' bit in the
> >> header and drop packets if it is set to ensure that we don't
> >> accidentally ignore critical options.
> >
> > Speaking of it, it's imho a bit too easy to confuse GENEVE_CRIT_OPT_TYPE
> > with the relevant 'C' bit mask.
> 
> Which 'C' bit mask? You mean the bitfield in the header? I guess but
> I'm not sure what would make it clearer and since they are different
> types it seems somewhat difficult to actually misuse them in practice.

What would you suggest, Francois?  A GENEVE_CRIT_OPT_PRESENT() macro?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
