From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delayscheduler
Date: Mon, 21 Jun 2004 12:06:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E017BA1BB@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jens Laas" <jens.laas@data.slu.se>,
        "Stephen Hemminger" <shemminger@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <tharbaugh@lnxi.com>, "David Greaves" <david@dgreaves.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thayne:

David did disable DITR and his problem did not go away. So, he is
definitely seeing a different issue.

Thanks,
ganesh 
 
-------------------------------------------------
Ganesh Venkatesan
Network/Storage Division, Hillsboro, OR

-----Original Message-----
From: Thayne Harbaugh [mailto:tharbaugh@lnxi.com] 
Sent: Monday, June 21, 2004 11:25 AM
To: David Greaves
Cc: Jens Laas; Stephen Hemminger; netdev@oss.sgi.com; Venkatesan, Ganesh
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+
delayscheduler

On Mon, 2004-06-21 at 11:29, David Greaves wrote:
> Thayne Harbaugh wrote:
> 
> >On Fri, 2004-06-18 at 03:08, David Greaves wrote:
> >
> >>Jens Laas wrote:
> >>    
> >>>We have tried different versions of e1000 without luck.
> >>>      
> >>>
> >>Me too, 3 cards.
> >>(did I mention I have 2 machines with very similar specs
(AMD/VIAKT600) 
> >>and the other one works - actually, to be accurate, hasn't yet
failed 
> >>but hasn't yet run at full speed - and it has a higher CPU speed)
> >>    
> >>
> >
> >What do you mean by, ". . . hasn't yet run at full speed - and it has
a
> >higher CPU speed . . ." ?  Does this mean that you can't get the card
to
> >have a reasonable throughput (~900Mbps)?
> >
> 
> It sounded reasonable when I wrote it :)
> 
> I have 2 machines I can easily test with (wired back to back)
> Machine 1 has an AMD3000+ CPU, machine 2 has an AMD3200+ cpu (maybe
not 
> relevant - maybe important if it's timing related?)
> 
> Machine one  stalls within a few kb.
> Machine two has shown no signs of failure yet.
> 
> However the other machine has not been stressed at all so it has 'not 
> yet run at full speed' - not surprising since it has no friends with 
> working gigabit cards :)

I have found a problem where the e1000 driver doesn't allow the hardware
to "run at full speed."  I think, however, that it is a different
problem than what you have found.  The dynamic interrupt throttling
(DITR) code in the 5.x e1000 drivers is horribly broken and throttles
interrupts (and therefore throughput) even when there are plenty of
resources for handling the interrupts and throughput.  Consequently the
performance is ~350Mbps when it should be ~900Mbps.

If you ever get your cards working correctly and are interested to get
the best performance then send me an email.  Alternatively, you can
search for my posts in the archives.

-- 
Thayne Harbaugh
Linux Networx
