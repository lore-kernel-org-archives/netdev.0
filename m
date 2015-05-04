From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next 0/8] Convert some skb_<foo> functions to
 void
Date: Mon, 04 May 2015 13:32:30 -0700
Message-ID: <1430771550.2872.7.camel@perches.com>
References: <cover.1430769294.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0086.hostedemail.com ([216.40.44.86]:48376 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751036AbbEDUcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:32:33 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay05.hostedemail.com (Postfix) with ESMTP id 88E30269195
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:32:32 +0000 (UTC)
Received: from joe-X200MA.home (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:32:31 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-04 at 13:05 -0700, Joe Perches wrote:
> unsigned char * return values are sometimes awkward to work with.
> Changing the return to void * is sometimes clearer.
> 
> The only uses of the return type is to do sets like
>     *skb_puts(skb, 1) = char;
>     
> Adding another function specifically for that purpose allows the return
> type to become void.

Obviously, this shouldn't be applied as-is.

It spans too many subsystems and can be done
more incrementally.

Also, there are some missing conversions so
this won't compile properly (sorry 'bout that)

These will also need conversions:

drivers/isdn/i4l/isdn_ppp.c:1311:       *skb_push(skb, 4) = 1; /* indicate outbound */
drivers/net/ppp/ppp_generic.c:1208:             *skb_push(skb, 2) = 1;
drivers/net/ppp/ppp_generic.c:1843:                     *skb_push(skb, 2) = 0;
drivers/nfc/pn533.c:2601:                               *skb_push(frag, sizeof(u8)) =
drivers/nfc/pn533.c:2604:                               *skb_push(frag, sizeof(u8)) =  1; /* TG */
drivers/nfc/pn533.c:2671:                       *skb_push(skb, sizeof(u8)) =  1; /* TG */
net/nfc/digital_dep.c:152:              *skb_push(skb, sizeof(u8)) = DIGITAL_NFC_DEP_NFCA_SOD_SB;
net/nfc/digital_technology.c:1164:      *skb_push(skb, sizeof(u8)) = size + 1;
net/nfc/rawsock.c:145:  *skb_push(skb, NFC_HEADER_SIZE) = 0;

The isdn and ppp_generic uses maybe should be
2 lines each for a little better clarity.
