From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling for ATM/ADSL
	(userspace)
Date: Tue, 20 Jun 2006 10:06:10 -0400
Message-ID: <1150812370.5270.27.camel@jzny2>
References: <1150278040.26181.37.camel@localhost.localdomain>
	 <1150282625.3490.23.camel@localhost.localdomain>
	 <1150332449.8605.40.camel@ras.pc.brisbane.lube>
	 <1150376591.5116.36.camel@jzny2>
	 <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Russell Stuart <russell-tcatm@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:15323 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750824AbWFTOGO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:06:14 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fsgrw-0004PX-Bl
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 10:06:16 -0400
To: Jesper Dangaard Brouer <hawk@diku.dk>
In-Reply-To: <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


took off lartc off the list because it doesnt allow me to post
and i refuse to subscribe.

On Mon, 2006-19-06 at 21:31 +0200, Jesper Dangaard Brouer wrote:
> 
> On Thu, 15 Jun 2006, jamal wrote:
> > It is probably doable by just looking at netdevice->type and figuring
> > the link layer technology. Totally in user space and building the
> > compensated for tables there before telling the kernel (advantage is no
> > kernel changes and therefore it would work with older kernels as well).
> 
> I think you have got the setup all wrong.
> 
> The linux middlebox/router has two ethernet interfaces, one of the 
> ethernet interfaces is connected to the ADSL modem.  Thus, the linux 
> ethernet card cannot determine that it is connected to an ADSL line.
> 

Actually you may be making my point for me.

Heres the standard setup as i understand it(at least in north america, I
know Europeans love their ATM with a little gravy on top):

                                                                       
|Linux| --ethernet-- |Modem| --DSL-- |DSLAM| --ATM-- |BRAS| 

    
What this means is that Linux computes based on ethernet
headers. Somewhere downstream ATM (refer to above) comes in and that
causes mismatch in what Linux expects to be the bandwidth and what
your service provider who doesnt account for the ATM overhead when
they sell you "1.5Mbps".
Reminds me of hard disk vendors who define 1K to be 1000 to show
how large their drives are.
Yes, Linux cant tell if your service provider is lying to you.

> 
> The patch is the solution to the classical problem people 
> have when tryng to configure traffic control on an ADSL link?
> 
> Q: The packet scheduling does not work all the time?
> A: Try to decrease to bandwidth.
> 
>
> The issue here is, that ATM does not have fixed overhead (due to alignment 
> and padding).  This means that a fixed reduction of the bandwidth is not 
> the solution.  We could reduce the bandwidth to the worst-case overhead, 
> which is 62%, I do not think that is a good solution...
> 

I dont see it as wrong to be honest with you. Your mileage may vary.

> With the patch, you can now simply configure HTB to use the rate that was 
> specified by the ISP.
> 


Dont have time to read your doc and dont get me wrong, there is a
"quark" practical problem: As practical as the hard disk manufacturer
who claims that they have 11G drive when it is 10G. It needs to be
resolved - but not in an intrusive way in my opinion.

cheers,
jamal



