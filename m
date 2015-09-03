From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next] xen-netback: add support for
 multicast control
Date: Thu, 3 Sep 2015 10:56:39 +0100
Message-ID: <1441274199.26292.324.camel@citrix.com>
References: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
	 <55E82768020000780009F32F@prv-mh.provo.novell.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD02F5B0516@AMSPEX01CL01.citrite.net>
	 <1441272682.26292.309.camel@citrix.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD02F5B05DA@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22776 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795AbbICJ6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 05:58:19 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD02F5B05DA@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-03 at 10:34 +0100, Paul Durrant wrote:
> > 
> > -----Original Message-----
> > From: Ian Campbell [mailto:ian.campbell@citrix.com]
> > Sent: 03 September 2015 10:31
> > To: Paul Durrant; Jan Beulich
> > Cc: Wei Liu; xen-devel@lists.xenproject.org; netdev@vger.kernel.org
> > Subject: Re: [Xen-devel] [PATCH v2 net-next] xen-netback: add support 
> > for
> > multicast control
> > 
> > On Thu, 2015-09-03 at 10:00 +0100, Paul Durrant wrote:
> > > > 
> > > > -----Original Message-----
> > > > From: Jan Beulich [mailto:JBeulich@suse.com]
> > > > Sent: 03 September 2015 09:57
> > > > To: Paul Durrant
> > > > Cc: Ian Campbell; Wei Liu; xen-devel@lists.xenproject.org;
> > > > netdev@vger.kernel.org
> > > > Subject: Re: [Xen-devel] [PATCH v2 net-next] xen-netback: add 
> > > > support
> > > > for
> > > > multicast control
> > > > 
> > > > > > > On 02.09.15 at 18:58, <paul.durrant@citrix.com> wrote:
> > > > > @@ -1215,6 +1289,31 @@ static void xenvif_tx_build_gops(struct
> > > > xenvif_queue *queue,
> > > > >  				break;
> > > > >  		}
> > > > > 
> > > > > +		if (extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 
> > > > > 1].type)
> > > > > {
> > > > > +			struct xen_netif_extra_info *extra;
> > > > > +
> > > > > +			extra =
> > > > &extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 1];
> > > > > +			ret = xenvif_mcast_add(queue->vif, extra
> > > > > -
> > > > > u.mcast.addr);
> > > > 
> > > > What's the reason this call isn't gated on vif->multicast_control?
> > > > 
> > > 
> > > No particular reason. I guess it eats a small amount of memory for no
> > > gain but a well behaved frontend wouldn't send such a request and a
> > > malicious one can only send 64 of them before netback starts to 
> > > reject
> > > them.
> > 
> > Perhaps a confused guest might submit them thinking they would work
> > when
> > actually the feature hasn't been properly negotiated and since it would
> > succeed it wouldn't generate an error on the guest side?
> 
> It would, but that's essentially harmless to functionality. If the 
> feature had not been negotiated properly then multicast flooding would 
> still be in operation so the guest would not lose any multicasts. I can 
> tighten things up if you like but as you say below it is a bit of a 
> corner case.

Ah yes, I had something backwards and thought the guest might miss out on
something it was expecting, but as you say it will just get more than it
wanted.
