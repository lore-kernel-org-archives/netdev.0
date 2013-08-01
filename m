From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2 3/3] ethernet: Convert mac address uses of 6 to
 ETH_ALEN
Date: Thu, 01 Aug 2013 13:55:28 -0700
Message-ID: <1375390528.2034.77.camel@joe-AO722>
References: <cover.1375387593.git.joe@perches.com>
	 <4170130535e4ea14c66f8510042577be21941f4d.1375387593.git.joe@perches.com>
	 <CAOesGMhmxJTDjcPeD4b1FvRsbP8df369F01SQBK6dk4nXmRGjA@mail.gmail.com>
	 <20130801203343.GG23006@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, Sam Creasey <sammy@sammy.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Network Development <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Don Fry <pcnet32@frontier.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Andrew Gallatin <gallatin@myri.com>, linux-driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49350 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752339Ab3HAUza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 16:55:30 -0400
In-Reply-To: <20130801203343.GG23006@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 21:33 +0100, Russell King - ARM Linux wrote:
> On Thu, Aug 01, 2013 at 01:31:09PM -0700, Olof Johansson wrote:
> > Hi,

Hi all.

> > On Thu, Aug 1, 2013 at 1:14 PM, Joe Perches <joe@perches.com> wrote:
> > > diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.h b/drivers/net/ethernet/pasemi/pasemi_mac.h
[]
> > > @@ -79,11 +79,11 @@ struct pasemi_mac {
> > >         int             last_cs;
> > >         int             num_cs;
> > >         u32             dma_if;
> > > -       u8              type;
> > >  #define MAC_TYPE_GMAC  1
> > >  #define MAC_TYPE_XAUI  2
> > >
> > > -       u8              mac_addr[6];
> > > +       u8              mac_addr[ETH_ALEN];
> > > +       u8              type;
> > 
> > Just promote 'type' to u32 instead, saves you from moving the #defines
> > down, etc, etc.

type is already u8, why change it?
That would also change struct size.

> There's a more fundamental question which has to be asked: what is the
> point of moving that in the first place?

Some is_<foo>_ether_addr tests assume __aligned(2)
by a casting char * to u16/be16 * and dereferencing.

see patch 0/3 and include/linux/etherdevice.h
