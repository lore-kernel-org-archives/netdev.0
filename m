From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Thu, 15 Jun 2006 09:16:23 -0400
Message-ID: <1150377383.5116.38.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150289724.26181.74.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl, russell-tcatm@stuart.id.au, hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:48806 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030396AbWFONQ2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 09:16:28 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fqri2-0003UH-C6
	for netdev@vger.kernel.org; Thu, 15 Jun 2006 09:16:30 -0400
To: Jesper Dangaard Brouer <hawk@comx.dk>
In-Reply-To: <1150289724.26181.74.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-14-06 at 14:55 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 2006-06-14 at 08:06 -0400, jamal wrote:

> > - Have you tried to do a long-lived session such as a large FTP and 
> > seen how far off the deviation was? That would provide some interesting
> > data point.
> 
> The deviation can be calculated.  The impact is of cause small for large
> packets.  
>
> But the argument that bulk TCP transfers is not as badly
> affected, is wrong because all the TCP ACK packets gets maximum penalty.
> 

ACKs have always played a prominent role. The last numbers i have seen
for North America (but i think probably valid globaly) show in the range
of 40% ACKs in internet traffic
http://netweb.usc.edu/~rsinha/pkt-sizes/
I suspect a lot of these stats are on their way to change with voip, p2p
etc.
But i dont think it is ACKs perse that you or Russell are contending
cause these issues. It's the presence of ATM . And all evidence seems to
point to the fact that ISPs bill you for something other than your
point of view, no?

> On an ADSL link with more than 8 bytes overhead, a 40 bytes TCP ACK will
> use more that one ATM frame, causing 2 ATM frames to be send that
> consumes 106 bytes, eg. 62% overhead.  On a small upstream ADSL line
> that hurts! (See thesis page 53, table 5.3 "Overhead summary").
> 

But how are you connected to the DSLAM? In north America it is typically
ethernet. If i use the current tables i dont see much of a problem with
say cable modems. Are you trying to compensate for the accounting
differences between what your service provider measures (accounting for
their ATM cells) and what you do accounting for your ethernet frames? 
I guess i am lost as to where the ATM is in the topology and more
importantly whether we (Linux) mis-account or whether your approach is
trying to compensate for the ISPs mis-accounting.

> 
> > - To be a devil's advocate (and not claim there is no issue), where do
> > you draw the line with "overhead"? 
> > Example the smallest ethernet packet is 64 bytes of which 14 bytes are
> > ethernet headers ("overhead" for IP) - and this is not counting CRC etc.
> > If you were to set an MTU of say 64 bytes and tried to do a http or ftp,
> > how accurate do you think the calculation would be? I would think not
> > very different.
> 
> I do think we handle this situation, but I'm not quite sure that I fully
> understand the question (sorry).
> 

Assume the following:
- You had ethernet end to end. Is there still a problem?
- Take it a notch up and assume you had ethernet with MTU of 64B. This
way you will have all your packets being small and having high overhead.
Do you still have a problem?

> 
> > Does it matter if it is accurate on the majority of the cases?
> > - For further reflection: Have you considered the case where the rate
> > table has already been considered on some link speed in user space and
> > then somewhere post-config the physical link speed changes? This would
> > happen in the case where ethernet AN is involved and the partner makes
> > some changes (use ethtool). 
> >
> > I would say the last bullet is a more interesting problem than a corner
> > case of some link layer technology that has high overhead.
> 
> We only claim to do magic on ATM/ADSL links... nothing else ;-)
> 

This is well and good given the focus of your thesis. Up/down here we
need something more generic. Your masters-thesis is a good start but
consider doing the phd next and complete this work;->

> 
> > Your work would be more interesting if it was generic for many link
> > layers instead of just ATM.
> 
> Well, we did consider to do so, but we though that it would be harder to
> get it into the kernel.
> 
> Actually thats the reason for the defines:
>  #define	ATM_CELL_SIZE		53
>  #define	ATM_CELL_PAYLOAD	48
> 
> Changing these should should make it possible to adapt to any other SAR
> (Segment And Reasembly) link layer.  
> 

You are still speaking ATM (and the above may still be valid), but: 
Could you for example look at the netdevice->type and from that figure
out the link layer overhead and compensate for it.
Obviously a lot more useful if such activity is doable in user space
without any knowledge of the kernel? and therefore zero change to the
kernel and everything then becomes forward and backward compatible.

cheers,
jamal

