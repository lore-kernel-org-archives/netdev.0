From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 0/4] net: Revive fixed link support
Date: Sat, 18 Jul 2009 12:37:34 -0600
Message-ID: <fa686aa40907181137v4a0ed1ednfed3194d1308296a@mail.gmail.com>
References: <20090717065220.15652.93331.stgit@localhost.localdomain>
	<20090718180448.GA3252@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, afleming@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	leoli@freescale.com
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:42798 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZGRShz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2009 14:37:55 -0400
Received: by gxk9 with SMTP id 9so2705089gxk.13
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2009 11:37:54 -0700 (PDT)
In-Reply-To: <20090718180448.GA3252@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 18, 2009 at 12:04 PM, Anton
Vorontsov<avorontsov@ru.mvista.com> wrote:
> On Fri, Jul 17, 2009 at 01:31:25AM -0600, Grant Likely wrote:
> [...]
>> Part of the problem I think is that the phylib code merges two separ=
ate
>> constructs; the construct of an MDIO bus (on which many device may
>> reside, not all of them PHYs), and the construct of an MII link whos=
e
>> speed and configuration need to be manipulated. =A0I've run into pro=
blems
>> myself on how best to handle things like Ethernet switches which
>> definitely do not behave like PHYs and the phylib state machine cann=
ot
>> be used on them. =A0It seems to me that the whole 'dummy phy' approa=
ch
>> is just an artifact of the phylib model not being quite right yet.
>
> Yep. With a bit of phylib rework we can remove all the MDIO emulation
> stuff from phy/fixed.c driver, and leave there just speed/duplex/paus=
e
> assignments.
>
> Though, I still believe that we should avoid two code paths in the
> drivers. One of the code paths will be constantly broken if we do so.

Yes, I agree.  Splitting the concepts also has the added advantage
that non-phy devices will have an interface to manipulate the link
speed without modifying drivers.

>> Anton, once again I don't have hardware to test this, so I rely on y=
ou
>> to tell be if I screwed it up. =A0It has been compile tested.
>
> Works fine here, thanks!

Awesome.  Dave, can you please pick up this series?

Thanks,
g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
