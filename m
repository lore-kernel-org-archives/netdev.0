From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Thu, 1 Oct 2015 18:34:36 -0300
Message-ID: <20151001213436.GB4890@localhost.localdomain>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc>
 <560B8E25.7050801@zonque.org>
 <20151001171323.GA4890@localhost.localdomain>
 <560DA092.60100@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbbJAVel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 17:34:41 -0400
Content-Disposition: inline
In-Reply-To: <560DA092.60100@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 01, 2015 at 11:07:30PM +0200, Daniel Mack wrote:
> On 10/01/2015 07:13 PM, Marcelo Ricardo Leitner wrote:
> > On Wed, Sep 30, 2015 at 09:24:21AM +0200, Daniel Mack wrote:
> >> On 09/29/2015 11:19 PM, Florian Westphal wrote:
> >>> Daniel Mack <daniel@zonque.org> wrote:
> >>>> Add a new chain type NF_INET_LOCAL_SOCKET_IN which is ran after the
> >>>> input demux is complete and the final destination socket (if any)
> >>>> has been determined.
> >>>>
> >>>> This helps filtering packets based on information stored in the
> >>>> destination socket, such as cgroup controller supplied net class IDs.
> >>>
> >>> This still seems like the 'x y' problem ("want to do X, think Y is
> >>> correct solution; ask about Y, but thats a strange thing to do").
> >>>
> >>> There is nothing that this offers over INPUT *except* that sk is
> >>> available.  But there is zero benefit as far as I am concerned --
> >>> why would you want to do any meaningful filtering based on the sk at
> >>> that point...?
> >>
> >> Well, INPUT and SOCKET_INPUT are just two different tools that help
> >> solve different classes of problems. INPUT is for filtering all local
> >> traffic while SOCKET_INPUT is just for such that actually has a
> >> listener, and they both make sense in different scenarios.
> > 
> > How is it better than -m socket ? It's used with tproxy, but not only,
> > and works quite well, thought it only supports TCP and UDP.
> 
> Yes, but not multicast.

Right

> > Something like
> >   iptables -N INPUT_SOCKET
> >   iptables -I INPUT -m socket -j INPUT_SOCKET
> > would achieve similar results, if I got you right.
> > 
> > -m socket implies in a double-lookup for the socket, yes, but that
> > sounds a reasonable price to pay for this while not inserting another
> > hook. I know of deployments using -m socket for tproxy and handling very
> > high rates, performance has not been a problem..
> 
> I know, and my primary attempt to get this fixed was to factor out the
> early demux code from the socket matching code and make it available to
> the cgroup matcher as well:
> 
> 
> http://thread.gmane.org/gmane.comp.security.firewalls.netfilter.devel/58054
> 
> That, however, got rejected because it doesn't work for multicast. This
> patch set implements one of the things Pablo suggested in his reply.

Ok, thanks for the info. Makes sense, hmm.

  Marcelo
