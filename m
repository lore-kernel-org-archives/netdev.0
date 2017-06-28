From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 4/9] nfp: extend flower
 add flow offload
Date: Wed, 28 Jun 2017 10:13:49 +0200
Message-ID: <20170628081347.GD9412@vergenet.net>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
 <1498605709-22574-5-git-send-email-simon.horman@netronome.com>
 <20170627231330.43a3f14a@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36583 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdF1INw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 04:13:52 -0400
Received: by mail-wm0-f50.google.com with SMTP id 62so45632033wmw.1
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 01:13:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170627231330.43a3f14a@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 11:13:30PM -0700, Jakub Kicinski wrote:
> On Wed, 28 Jun 2017 01:21:44 +0200, Simon Horman wrote:
> > diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> > index 9127c28ea9c3..8ad72f57493d 100644
> > --- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
> > +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> > @@ -45,6 +45,145 @@
> >  #include "../nfp_net.h"
> >  #include "../nfp_port.h"
> >  
> > +static bool nfp_flower_check_lower_than_mac(struct tc_cls_flower_offload *f)
> > +{
> > +	return dissector_uses_key(f->dissector,
> > +				  FLOW_DISSECTOR_KEY_IPV4_ADDRS) ||
> > +		dissector_uses_key(f->dissector,
> > +				   FLOW_DISSECTOR_KEY_IPV6_ADDRS) ||
> > +		dissector_uses_key(f->dissector,
> > +				   FLOW_DISSECTOR_KEY_PORTS) ||
> > +		dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ICMP);
> > +}
> 
> Nit: should this be named higher than mac?

Yes, I think so now you mention it.
I'll fix this in v2.
