From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Sat, 4 Apr 2015 03:01:42 +0200
Message-ID: <20150404010142.GA1063@electric-eye.fr.zoreil.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
 <CAEP_g=9PbDO4qK-GaGosBAq1S5C5uWNR4-JN8=i158oYJUN4Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47709 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbbDDBCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 21:02:30 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9PbDO4qK-GaGosBAq1S5C5uWNR4-JN8=i158oYJUN4Bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@nicira.com> :
[...]
> > diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> > new file mode 100644
> > index 000000000000..fe8895487fc2
> > --- /dev/null
> > +++ b/drivers/net/geneve.c
> > +/* geneve receive/decap routine */
> > +static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
> > +{
> > +       struct genevehdr *gnvh = geneve_hdr(skb);
> > +       struct geneve_dev *geneve;
> > +       struct pcpu_sw_netstats *stats;
> > +
> > +       geneve = gs->rcv_data;
> > +
> > +       /* Does the VNI match the device? */
> > +       if (memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)))
> > +               goto drop;
> 
> Since Geneve packets can carry options and this doesn't currently
> support any, I think we need to at least check the 'C' bit in the
> header and drop packets if it is set to ensure that we don't
> accidentally ignore critical options.

Speaking of it, it's imho a bit too easy to confuse GENEVE_CRIT_OPT_TYPE
with the relevant 'C' bit mask.

-- 
Ueimor
