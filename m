From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] Bluetooth: Silence static checker warning.
Date: Fri, 2 Mar 2012 09:15:37 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E88@saturn3.aculab.com>
References: <1330537602.3392.101.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <padovan@profusion.mobi>, <davem@davemloft.net>,
	<linux-bluetooth@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: "Marcel Holtmann" <marcel@holtmann.org>,
	"santosh nayak" <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1330537602.3392.101.camel@aeonflux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> > > diff --git a/net/bluetooth/l2cap_sock.c
b/net/bluetooth/l2cap_sock.c
> > > index 401d942..d206321 100644
> > > --- a/net/bluetooth/l2cap_sock.c
> > > +++ b/net/bluetooth/l2cap_sock.c
> > > @@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock,
struct sockaddr *addr, int alen)
> > >  	}
> > >  
> > >  	if (la.l2_cid)
> > > -		err = l2cap_add_scid(chan, la.l2_cid);
> > > +		err = l2cap_add_scid(chan, __le16_to_cpu(la.l2_cid));
> > >  	else
> > >  		err = l2cap_add_psm(chan, &la.l2_bdaddr, la.l2_psm);
> > >  
> > > @@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket
*sock, struct sockaddr *addr, int al
> > >  	if (la.l2_cid && la.l2_psm)
> > >  		return -EINVAL;
> > >  
> > > -	err = l2cap_chan_connect(chan, la.l2_psm, la.l2_cid,
&la.l2_bdaddr);
> > > +	err = l2cap_chan_connect(chan, la.l2_psm,
__le16_to_cpu(la.l2_cid),
> > > +				&la.l2_bdaddr);
> > >  	if (err)
> > >  		goto done;
> > 
> > I am not sure about this one. Need to go back and read through the
> > source code. The value provided from userspace is already in the
right
> > host endian. Could be that we mess up our internal classification.
And
> > instead of adding __le16_to_cpu we should fix its classification.
> 
> I confused myself here, so the provided PSM and CID values coming from
> userspace are little endian. Patch is correct.

How long has this code been in tree?
It isn't obvious to me that this change won't break code on BE systems
where the application code is already fixing the endianness.

	David
