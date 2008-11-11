From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Tue, 11 Nov 2008 15:40:01 -0600
Message-ID: <2acbd3e40811111340u4dabe6caoc01054ee3d7f844c@mail.gmail.com>
References: <1221524685-25968-1-git-send-email-afleming@freescale.com>
	 <490DA8B5.2020303@garzik.org>
	 <1226053017.29620.431.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Andy Fleming" <afleming@freescale.com>, netdev@vger.kernel.org
To: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:33785 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbYKKVkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 16:40:04 -0500
Received: by ey-out-2122.google.com with SMTP id 6so43380eyi.37
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 13:40:02 -0800 (PST)
In-Reply-To: <1226053017.29620.431.camel@gentoo-jocke.transmode.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2008 at 4:18 AM, Joakim Tjernlund
<joakim.tjernlund@transmode.se> wrote:
> On Sun, 2008-11-02 at 08:18 -0500, Jeff Garzik wrote:
>> Andy Fleming wrote:
>> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>> >
>> > Creating a VLAN interface on top of ucc_geth adds 4 bytes
>> > to the frame and the HW controller is not prepared to
>> > TX a frame bigger than 1518 bytes which is 4 bytes too
>> > small for a full VLAN frame. Also add 4 extra bytes for future
>> > expansion.
>> >
>> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>> > ---
>> >  drivers/net/ucc_geth.c |    6 +++---
>> >  1 files changed, 3 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
>> > index 8f944e5..8fed4bb 100644
>> > --- a/drivers/net/ucc_geth.c
>> > +++ b/drivers/net/ucc_geth.c
>> > @@ -113,10 +113,10 @@ static struct ucc_geth_info ugeth_primary_info = {
>> >     .maxGroupAddrInHash = 4,
>> >     .maxIndAddrInHash = 4,
>> >     .prel = 7,
>> > -   .maxFrameLength = 1518,
>> > +   .maxFrameLength = 1518+8, /* Add 4 bytes for VLAN tags and 4 extra bytes */
>> >     .minFrameLength = 64,
>> > -   .maxD1Length = 1520,
>> > -   .maxD2Length = 1520,
>> > +   .maxD1Length = 1520+8,
>> > +   .maxD2Length = 1520+8,
>> >     .vlantype = 0x8100,
>>
>> Is this still needed?
>>
>> I found this buried in my inbox.
>>
>> If so, please resend with the "+8" converted into a named constant.
>> Hardcoding lengths like this without named constants (or comments, on
>> the other lines) tends to be an error-prone practice.
>
> Yes, it is. I do recall the maintainer had some comments though.
> Secondly, I think it should be changed to 8 extra bytes so
> you can fit VLAN+pppoe=4+8 bytes. Possibly it could
> be configuarble at complile time.
>
> Andy, you think you can work out the details with the maintainer?
> I am much to busy ATM.


Hmm... me, too.  I'm not really familiar with this driver.  I suspect
that all of the stuff in that structure should be yanked out, and done
more sensibly, but I don't have time to do it.  I'll ping him about
it.

Andy
