From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/5] gtp: let userspace handle packets for invalid tunnels
Date: Tue, 24 Jan 2017 21:19:28 +0100
Message-ID: <20170124201928.GA11999@salvia>
References: <20170124172402.12096-1-aschultz@tpip.net>
 <20170124172402.12096-6-aschultz@tpip.net>
 <20170124190349.GA9757@salvia>
 <1060167008.597625.1485288151511.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, laforge <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54304 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750759AbdAXUTf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 15:19:35 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id DAC651EC2CD
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 21:19:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C922FA7E7D
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 21:19:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 19D55DA790
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 21:19:29 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1060167008.597625.1485288151511.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 09:02:31PM +0100, Andreas Schultz wrote:
> Hi Pablo,
> 
> ----- On Jan 24, 2017, at 8:03 PM, pablo pablo@netfilter.org wrote:
> 
> > Hi Andreas,
> > 
> > On Tue, Jan 24, 2017 at 06:24:02PM +0100, Andreas Schultz wrote:
> >> enable userspace to send error replies for invalid tunnels
> >> 
> >> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> >> ---
> >>  drivers/net/gtp.c | 8 ++++----
> >>  1 file changed, 4 insertions(+), 4 deletions(-)
> >> 
> >> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> >> index 912721e..c607333 100644
> >> --- a/drivers/net/gtp.c
> >> +++ b/drivers/net/gtp.c
> >> @@ -198,12 +198,12 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct
> >> sk_buff *skb,
> >>  	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
> >>  	if (!pctx) {
> >>  		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
> >> -		return -1;
> >> +		return 1;
> >>  	}
> >>  
> >>  	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
> >>  		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> >> -		return -1;
> >> +		return 1;
> > 
> > So userspace gets the packet that we cannot forward. I guess your
> > userspace codebase performs this sanity checks again so you can send
> > the appropriate error reply?
> 
> For TEID /= 0, the only reply is a T-PDU of type error indication. There
> is no cause specified. So I don't actually have to repeat the check.
> TEID == 0 is more interesting, this tells userspace that it tried to
> send on an invalid tunnel and should tear it down.

Ah, I see, thanks for explaining, I guess this is good to debug
misconfigurations.

> If you like, you can have a look at the userspace code. The relevant piece
> is at https://github.com/travelping/gtp_u_kmod/blob/master/src/gtp_u_kmod_port.erl#L231
> 
> But be warned, it's written in Erlang ;-)

Will have a look, but you taking me away from my usual domains :).
