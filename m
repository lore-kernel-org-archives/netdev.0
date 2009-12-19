From: Christian Samsel <christian.samsel@rwth-aachen.de>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Sat, 19 Dec 2009 11:38:16 +0100
Message-ID: <200912191138.16367.christian.samsel@rwth-aachen.de>
References: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
 <200912181901.28542.christian.samsel@rwth-aachen.de>
 <20091218.195907.189689401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:63193 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750767AbZLSKiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 05:38:16 -0500
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUW001V1AVRFLD0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sat, 19 Dec 2009 11:38:15 +0100 (CET)
Received: from oxygen-mobile.localnet ([unknown] [80.135.52.251])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0KUW005IVAVQ0N00@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Sat, 19 Dec 2009 11:38:15 +0100 (CET)
In-reply-to: <20091218.195907.189689401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 19. Dezember 2009 04:59:07 schrieb David Miller:
> From: Christian Samsel <christian.samsel@rwth-aachen.de>
> Date: Fri, 18 Dec 2009 19:01:28 +0100
> 
> > Am Freitag, 18. Dezember 2009 18:32:40 schrieb Stephen Hemminger:
> >> On Fri, 18 Dec 2009 14:18:37 +0100
> >>
> >> Christian Samsel <christian.samsel@rwth-aachen.de> wrote:
> >> > This patch adds a new feature to netem: The newly introduced parameter
> >> > reorderdelay TIME is the time a reordered packet is delayed. It can be
> >> > used in a combination with delay TIME to enable netem to produce late
> >> > packets, which is not possible in the standard netem / iproute2. In
> >> > the standard version reordered packets are always sent immediately and
> >> > therefore are always early packets.
> >>
> >> I like the idea but is it binary compatible with older kernels/ older
> >>  iproute2 utilities?
> >
> > Thats a good point. I will test it. So far i think it should work.
> 
> It won't work.
> 
> If you change the size of the tc_netem_qopt, older kernels will
> reject because the size is different from what the kernel expects.

I just tested it both ways (vanilla kernel + changed tc, changed kernel + 
vanilla tc). The reordering behaved wierd. But i did not see something like a 
"reject". Other netem features like DROP still worked fine.
Are you sure this can't be fixed in some way? From my feeling, it might be 
just a small tweaking in parameter handling necessary.

Obviously, sending the new data to an unchanged kernel won't work, but that 
should be ok, isn't it?

> So newer iproute2 will not work with older kernels.
> 
> You can't change these structures, add new netlink attributes
> to pass the new data instead.

I will look into this, but having similiar netem data in two different places 
seems awkward to me.
