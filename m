From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v4 2/8] 6lowpan: add uncompress header size
 function
Date: Wed, 26 Feb 2014 17:20:10 +0100
Message-ID: <20140226162008.GA11499@omega>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
 <1393430712-11298-3-git-send-email-alex.aring@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"martin.townsend@xsilon.com" <martin.townsend@xsilon.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:43419 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbaBZQUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 11:20:17 -0500
Received: by mail-ee0-f43.google.com with SMTP id e53so490548eek.2
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:20:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

thanks for your reply.

On Wed, Feb 26, 2014 at 04:10:05PM +0000, David Laight wrote:
> From: Alexander Aring
> > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > ---
> >  net/ieee802154/6lowpan.h | 116 +++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 116 insertions(+)
> > 
> > diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> > index 2b835db..b6ae0bc 100644
> > --- a/net/ieee802154/6lowpan.h
> > +++ b/net/ieee802154/6lowpan.h
> > @@ -306,6 +306,122 @@ static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
> >  	*hc_ptr += len;
> >  }
> > 
> > +static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
> > +{
> > +	switch (addr_mode) {
> > +	case LOWPAN_IPHC_ADDR_00:
> > +		return 16;
> > +	case LOWPAN_IPHC_ADDR_01:
> > +		return 8;
> > +	case LOWPAN_IPHC_ADDR_02:
> > +		return 2;
> > +	default:
> > +		return 0;
> > +	}
> > +}
> 
> The compiler will generate much better code if you index an array instead
> of using a switch statement.
> 
> 

You mean something like:

static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
{
        const u8 res[] = { 16, 8, 2, 0 };
        return res[addr_mode];
}

or should I drop the array from the stack and declare it static?

?

- Alex
