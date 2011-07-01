From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Fri, 1 Jul 2011 09:37:29 -0400
Message-ID: <20110701133729.GA22160@hmsreliant.think-freely.org>
References: <4DE44218.4070306@krellan.com>
 <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
 <4DE5F3E3.2080609@krellan.com>
 <1306949723.8149.2202.camel@tardy>
 <4E04A609.7010206@fandm.edu>
 <4E0C35F4.6050901@krellan.com>
 <20110630143614.GA4392@shamino.rdu.redhat.com>
 <4E0D87B6.8090108@krellan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: janardhan.iyengar@fandm.edu,
	Janardhan Iyengar <jana.iyengar@gmail.com>, rick.jones2@hp.com,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, Bryan Ford <bryan.ford@yale.edu>
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54649 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756496Ab1GANhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 09:37:50 -0400
Content-Disposition: inline
In-Reply-To: <4E0D87B6.8090108@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 01:39:18AM -0700, Josh Lehan wrote:
> On 06/30/2011 07:36 AM, Neil Horman wrote:
> > I'll leave the rest of this alone, since its pretty obvious that no one is going
> > to break TCP for you, but just so that you're aware, The only reason you have to
> 
> That's the fundamental disconnect we've been trying to communicate: TCP
> *won't break*.  None of the rules of TCP are broken, from the wire's
> point of view.  The OS merely gets a richer API, from the application's
> point of view, to optimize the TCP protocol implementation to serve a
> wider variety of needs.
> 
I get what you're saying, but a API change that is only available on linux is
still a break.  I get that its not an on-wire change, but API differences that
make code non-portable go unused, for exactly that reason - people don't write
apps that can only work on linux, they write standard apps that comply to
specifications.  Deviations from those standards go unused.  

I suppose it comes down to a difference of opinion about what "broken" amounts
to.  Either way, if you want to see this happen, I'm certain it will start with
you presenting code and illustrating its benefit.  No one else is going to write
this for you.

> > use the 2-Wire gateway that AT&T provides is because there are no commercially
> > available routers that support the uplink interface (which I expect will change
> 
> That would be good to give the customer a choice of access devices with
> which to get on the network, and let the market device what is best,
> instead of AT&T dictating what's allowed.  I'm getting deja vu of a
> famous legal case from 27 years ago.
> 
> > eventually).  In the time being, if you want to use a different router, place
> > the RG in bridge mode by selecting a host as your DMZ device.  That will assign
> > the wan address to that connected device via DHCP and allow you to pass whatever
> > traffic you want through it.  I use it to pass SCTP and IPv6 traffice all the
> > time, works great.
> 
> Wow, that's news to me, that it allows this.
> 
> http://www.ka9q.net/Uverse/
> 
> Have the limitations in these documents been addressed?  If so, kudos to
> AT&T.
> 
The limitations are overstated in the link above.  NAT is mandatory, but only
over the HPNA interface.  The idea is to prevent your set-top box that AT&T
communicates with from having a public ip address (to maintain quality of
service to the TV and prevent outside attacks).  They have one or two ports
forwarded from the public ip address to the private address of the set top box

In comparison the RJ-45 interfaces can be made wide open.  Specifically you can
attach a single device and mark it as the DMZ for the Residential gateway.
anything not forwarded to the set top box gets passed to the DMZ device. 

So its not 100% NAT free.  Its wide open, minus a single port to allow AT&T to
push content to your set top box.

It works pretty well.  I marked v6rotuer.think-freely.org as my DMZ device and
use it to do my own internal NAT-ing for IPv4 as well as serve as the tunnel
enpoint and router for my IPv6 network.  
Neil

> Josh Lehan
> 
