From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 net-next] tuntap: convert to 64-bit interface
 statistics
Date: Thu, 19 Mar 2015 18:04:17 -0700
Message-ID: <1426813457.25985.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426794689-29943-1-git-send-email-jtoppins@cumulusnetworks.com>
	 <1426801109.25985.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <550B4619.6020203@cumulusnetworks.com>
	 <1426805764.25985.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <550B6124.7070001@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Curt Brune <curt@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33118 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbbCTBER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 21:04:17 -0400
Received: by ignm3 with SMTP id m3so21076294ign.0
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 18:04:16 -0700 (PDT)
In-Reply-To: <550B6124.7070001@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 19:52 -0400, Jonathan Toppins wrote:
> On 3/19/15 6:56 PM, Eric Dumazet wrote:
> > On Thu, 2015-03-19 at 17:56 -0400, Jonathan Toppins wrote:
> >
> >
> >> Or are you suggesting per-cpu counters would be preferred which would
> >> possibly eliminate the need for this lock?
> >
> > Might be overkill for a device that is probably used by one cpu,
> > considering you defined a full  struct rtnl_link_stats64, instead of the
> > fields that are really handled.
> >
> 
> Ok. So summarizing for v2, so far; eliminating the back-to-back lock -> 
> release -> lock -> release is preferred (I agree with this).
> 
> It still seems like you are not a huge fan of the additional lock, 
> should I hold off on sending v2 for a day, so we can ponder alternatives?

It seems you need a lock only in RX, for 2 vars only.
(rx_packets & rx_bytes)

error counters are generally OK with unsigned long, nobody will complain
of possible concurrent non atomic updates.

So maybe percpu var for these 16 bytes would be OK.
