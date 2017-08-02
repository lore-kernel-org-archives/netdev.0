From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v1 1/3] gtp: refactor to support flow-based gtp
 encap and decap
Date: Wed, 2 Aug 2017 14:52:46 +0200
Message-ID: <20170802125246.GA4856@salvia>
References: <20170713004455.3946570-1-ouyangj@fb.com>
 <20170713004455.3946570-2-ouyangj@fb.com>
 <1825145503.799984.1501485696720.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiannan Ouyang <ouyangj@fb.com>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>, dev@openvswitch.org,
        laforge <laforge@gnumonks.org>, pshelar@nicira.com,
        wieger ijntema tno <wieger.ijntema.tno@gmail.com>,
        yi y yang <yi.y.yang@intel.com>, joe@ovn.org,
        Amar Padmanabhan <amarpadmanabhan@fb.com>
To: Andreas Schultz <aschultz@tpip.net>, g@salvia
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:51704 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751174AbdHBMxS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 08:53:18 -0400
Content-Disposition: inline
In-Reply-To: <1825145503.799984.1501485696720.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 09:21:36AM +0200, Andreas Schultz wrote:
> Hi Jiannan,
> 
> ----- On Jul 13, 2017, at 2:44 AM, Jiannan Ouyang ouyangj@fb.com wrote:
> 
> [...]
> 
> > -static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
> > -			unsigned int hdrlen, unsigned int role)
> > +static int gtp_rx(struct gtp_dev *gtp, struct sk_buff *skb,
> > +		  unsigned int hdrlen, struct sock *sk,
> > +		  struct metadata_dst *tun_dst)
> 
> Some time ago, there was an extensive discussion about the relation
> of PDP context and network devices. You are basically reverting one
> of the changes that was made in that context. I think it is wrong to
> couple GTP devices and PDP context the way you do here (there are
> people that disagree, though).
> 
> The GTP network device of one of two structures owning the PDP context,
> the other is the GTP socket. GTP network devices and GTP sockets should
> be strictly separated.
> 
> The GTP network device owns the IP given to the MS, handles mapping
> IP's into GTP tunnels (peer GSN + TEIDs) and hands the resulting GTP 
> packets of to the GTP socket for sending. The GTP socket decaps the GTP
> packet, find the right context and based on information therein passes
> it to the GTP network device.
> 
> By separating is that way, you can have MS with overlapping or colliding
> IP's on the same GTP socket as long as they belong to different GTP network
> devices.
> 
> We had a length discussion about whether the above scenario makes sense.
> I'm not sure if we reached a final verdict, but the 3GPP specifications
> clearly permit such a setup.

We need a netlink interface to retrieve GTP information accordingly,
this includes a top-level APN object to represent what you need. That
would allow to accomodate all usecases.
