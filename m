From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 8/9] bnx2x: further annotations
Date: Thu, 22 Jan 2009 10:17:04 -0800
Message-ID: <1232648224.9701.53.camel@brick>
References: <1232517051.9701.26.camel@brick>
	 <1232646594.29087.88.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:64141 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007AbZAVSRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 13:17:07 -0500
Received: by wf-out-1314.google.com with SMTP id 27so5077820wfd.4
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 10:17:06 -0800 (PST)
In-Reply-To: <1232646594.29087.88.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-22 at 19:49 +0200, Eilon Greenstein wrote:
> On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> > No functional annotations, just documenting the status quo.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> [...]
> 
> > @@ -9699,11 +9699,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  						 bd_prod, ++nbd);
> >  
> >  		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
> > -		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
> > +		pbd->tcp_send_seq = cpu_to_le32(be32_to_cpu(tcp_hdr(skb)->seq));
> 
> Hmmm.... That looks worse to me. Do we really need to replace swab with
> cpu_to_le on top of be_to_cpu?

Agreed that it is ugly, in a future patch I was thinking of changing tcp_send_seq
to just be treated as a be-value throughout the driver, or at least a cpu-endian.

These patches are more about documenting the status quo than making functional
changes like that, so I went with the somewhat ugly annotation for now.  Once
the endian noise has been reduced, it will be a lot easier to make changes
without introducing bugs.

Harvey

