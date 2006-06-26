From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Mon, 26 Jun 2006 09:34:46 -0500
Message-ID: <1151332486.2398.20.camel@stevo-desktop>
References: <54AD0F12E08D1541B826BE97C98F99F15F55E2@NT-SJCA-0751.brcm.ad.broadcom.com>
	 <20060622.155805.35017169.davem@davemloft.net>
	 <1151024186.5099.46.camel@jzny2>  <1151069083.7808.19.camel@stevo-desktop>
	 <1151159405.6716.106.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:64568 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1030231AbWFZOes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 10:34:48 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151159405.6716.106.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-06-24 at 10:30 -0400, jamal wrote:
> On Fri, 2006-23-06 at 08:24 -0500, Steve Wise wrote:
> 
> > 
> > > PS:- I do think what they need is to hear route cache generation
> > > as opposed to ARP+FIB updates; but lets wait and see how clever 
> > > the patches would look.
> > > 
> 
> > Can you expand on your statement above?  If hooking route cache
> > generation gets all the events I described, then I'd like to use that.
> > I'm still learning the Linux routing subsystem.  Any help would be
> > GREAT!
> > 
> 
> If my understanding is correct of what you are trying to do is:
> for a destination IP you are going to figure the source and destination
> MAC address. Most of that info is available at the route + hh cache. 
> There can be only one destination mac per device and so you only need to
> watch the device changes for that. The dst MAC per IP and any changes
> you can glean from the route cache created.
> But this is based on my understanding of what you are trying to do and
> so far i cant say i am 100% clear.

The route/hh cache insertions might work for the initial dst MAC per
next-hop IP.  But this dst MAC can _change_ for various reasons (even
though the next-hop IP remains the same).   Such a change, I think,
doesn't generate a new route + hh cache insertion, just a change to the
hh entry.

Also, I think the route cache entry is created _before_ the MAC addr is
known. So we really need to know when the neighbour entry is updated
with the MAC address as a result of ARP/ND.  Hooking the correct spot in
the neighbour code where the mac address gets stored also gets us the
change event I described above.

Does this make sense?

Steve.

