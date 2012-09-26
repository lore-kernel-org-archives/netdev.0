From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: flow control handling in network driver
Date: Wed, 26 Sep 2012 15:49:49 +0200
Message-ID: <1348667389.10741.34.camel@deadeye.wl.decadent.org.uk>
References: <CAJ3bTp4J4aLzPgDND6E6SMXZe05xnM7K9kHVCH7kD-=vYZNtHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60261 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756555Ab2IZNtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 09:49:53 -0400
In-Reply-To: <CAJ3bTp4J4aLzPgDND6E6SMXZe05xnM7K9kHVCH7kD-=vYZNtHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-26 at 14:48 +0530, Rayagond K wrote:
> Hi All,
> 
> What is the use of two macros SUPPORTED_Pause and SUPPORTED_Asym_Pause
> which are defined in ethtool.h file.
> 
> I have seen amny driver in lxr using above macros, for example tg3
> driver - uses these macros to advertise the phy capabilities.
> 
> Flow control is MAC feature not PHY, hence when can one use above
> macros and what is the use of it. Should we use these macros to
> implement flow control in Ethernet driver ?

Ethernet autonegotiation includes flow control as well as speed and
duplex (and some other parameters).  Any device that supports Ethernet
flow control and autonegotiation should set the supported flags
accordingly and check the advertised flags when programming the PHY for
autonegotiation.  (This is complicated a bit by the separate ethtool
commands for flow control.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
