From: Joe Perches <joe@perches.com>
Subject: Re: [RFC 1/3] networking: make skb_put & friends return void
 pointers
Date: Fri, 16 Jun 2017 04:26:36 -0700
Message-ID: <1497612396.10546.7.camel@perches.com>
References: <20170615221217.16510-1-johannes@sipsolutions.net>
         <20170615221217.16510-2-johannes@sipsolutions.net>
         <871sqke5co.fsf@miraculix.mork.no>
         <1497602577.2622.5.camel@sipsolutions.net>
         <1497609558.10546.5.camel@perches.com>
         <1497611020.2622.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0138.hostedemail.com ([216.40.44.138]:51965 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752372AbdFPL0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 07:26:39 -0400
In-Reply-To: <1497611020.2622.8.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 13:03 +0200, Johannes Berg wrote:
> On Fri, 2017-06-16 at 03:39 -0700, Joe Perches wrote:
> > 
> > I would suggest avoiding using skb_put_u8 as it
> > would suggest there should be skb_put_u16 etc
> 
> If there are enough users, I don't know why we wouldn't add it? Though
> it should be _unaligned_le16 and _unaligned_be16, if at all :)

Maybe.

Avoid api explosion can be good.

Maybe using skb_put_data() and optimizing away size
using __builtin_constant_p and a switch statement
could do more or less the same thing.

$ git grep -P "\*\s*\(.*\*\s*\)\s*skb_put" *
drivers/net/wireless/intel/ipw2x00/ipw2200.c:		*(__le16*)skb_put(dst, sizeof(u16)) = cpu_to_le16(
drivers/net/wireless/intel/ipw2x00/ipw2200.c:			*(__le16*)skb_put(dst, sizeof(u16)) =
drivers/net/wireless/intel/ipw2x00/ipw2200.c:			*(__le16*)skb_put(dst, sizeof(u16)) =
drivers/net/wireless/intel/ipw2x00/ipw2200.c:			*(__le16*)skb_put(dst, sizeof(u16)) =
drivers/s390/net/ctcm_fsms.c:		*((__u16 *)skb_put(ch->trans_skb, 2)) = ch->collect_len + 2;
drivers/atm/fore200e.c:	*((u32*)skb_put(skb, 4)) = cell_header;
net/l2tp/l2tp_ip.c:	*((__be32 *) skb_put(skb, 4)) = 0;
net/atm/signaling.c:	*(struct atmsvc_msg *)skb_put(skb, sizeof(struct atmsvc_msg)) = *msg;
