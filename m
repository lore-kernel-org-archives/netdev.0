From: kuznet@ms2.inr.ac.ru
Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 17:31:44 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207301331.RAA03211@sex.inr.ac.ru>
References: <20020730131424.GA25238@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, akpm@zip.com.au, jgarzik@mandrakesoft.com,
   becker@scyld.com
Return-path: <owner-netdev@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20020730131424.GA25238@outpost.ds9a.nl> from "bert hubert" at Jul 30, 2 03:14:25 pm
List-Id: netdev.vger.kernel.org

Hello!

> Regarding Andi's message, isn't it so that recvfrom() may return but in that
> case returns -1 and sets errno to EAGAIN?

It should if we calculated this checksum. But 3com pretends to do this
in hardware. :-)


> Anything I can do to help,

Well, try to prove that corrupted packet is really received by application.
This is not useless work, in any case, you have to cure this place,
it should not abort because of invalid data. :-)

As a faster hint try to disable rx checksumming in the driver
and look at the effect. I do not see module option to do this,
so probably you have just to comment out the place where
skb->ip_summed is set to CHECKSUM_UNNECESSARY.

Alexey
