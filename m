From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 13:58:07 +0200
Message-ID: <1497527887.2518.6.camel@sipsolutions.net>
References: <20170615092804.19400-1-johannes@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC901A@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48034 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752416AbdFOL6J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 07:58:09 -0400
In-Reply-To: <8729016553E3654398EA69218DA29EEF15BC901A@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 09:54 +0000, YUAN Linyu wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel
> > .org]
> > On Behalf Of Johannes Berg
> > Sent: Thursday, June 15, 2017 5:28 PM
> > To: netdev@vger.kernel.org
> > Cc: Johannes Berg
> > Subject: [RFC v2] networking: convert many more places to
> > skb_put_zero()
> > 
> > From: Johannes Berg <johannes.berg@intel.com>
> > diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> > index ea2601501654..aaac2660aaf7 100644
> > --- a/net/sctp/sm_make_chunk.c
> > +++ b/net/sctp/sm_make_chunk.c
> > @@ -1478,10 +1478,9 @@ void *sctp_addto_chunk(struct sctp_chunk
> > *chunk,
> > int len, const void *data)
> >  	int chunklen = ntohs(chunk->chunk_hdr->length);
> >  	int padlen = SCTP_PAD4(chunklen) - chunklen;
> > 
> > -	padding = skb_put(chunk->skb, padlen);
> > +	padding = skb_put_zero(chunk->skb, padlen);
> 
> "padding" will become unused. 
> I know this place when I check.

Yeah, I figured that would happen. I could try to make the spatch catch
that too, but I'm not sure I can figure out how to :)

johannes
