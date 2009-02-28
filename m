From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] igb: remove skb_orphan calls
Date: Fri, 27 Feb 2009 17:02:48 -0800
Message-ID: <9929d2390902271702v19deb711v4d729b4cb7dad1e6@mail.gmail.com>
References: <80769D7B14936844A23C0C43D9FBCF0F283B6220@orsmsx501.amr.corp.intel.com>
	 <20090227031421.GA21036@gondor.apana.org.au>
	 <80769D7B14936844A23C0C43D9FBCF0F283B712F@orsmsx501.amr.corp.intel.com>
	 <20090227.161011.220557653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, herbert@gondor.apana.org.au,
	emil.s.tantilov@intel.com, patrick.ohly@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.217.174]:53709 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbZB1BCu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 20:02:50 -0500
Received: by gxk22 with SMTP id 22so3260634gxk.13
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 17:02:48 -0800 (PST)
In-Reply-To: <20090227.161011.220557653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 4:10 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
> Date: Fri, 27 Feb 2009 08:39:30 -0800
>
>> The fact is, if you are planning to kill it further up the stack,
>> you can put that down as another reason for removing the call. =C2=A0=
The
>> timesync / killing skb->sk is a separate discussion that I don't
>> know if I even really need to be involved in. =C2=A0The patch doesn'=
t
>> break anything, and removes a call to skb_orphan that shouldn't
>> really be there in the first place.
>
> That's not true at all.
>
> One reason we haven't removed it yet is because there are some
> semantic issues to address, which are also effected by drivers
> doing this kind of by-hand skb_orphan()'ing.
>
> For one thing, if you skb_orphan() in your transmit handler,
> a UDP application can take over your network card by just
> transmitting in an endless tight loop. =C2=A0It would be able to
> nearly keep all other users from using the card.
>
> That happens because if you skb_orphan(), nothing controls the
> pace at which datagram applications can send. =C2=A0Currently
> we need the socket send buffer limits to help us out here,
> but if you skb_orphan() you completely subvert that proptection.
>
> So I will not apply this patch.
> --

So the removal of the skb_orphan() in the driver should be a good
thing, the only issue is with the patch description?  By cleaning up
the patch description, will that make this patch acceptable for
everyone?

--=20
Cheers,
Jeff
