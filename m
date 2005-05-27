From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Fri, 27 May 2005 10:57:02 -0400
Message-ID: <1117205822.6383.68.camel@localhost.localdomain>
References: <20050526185306.GW15391@postel.suug.ch>
	 <20050526185526.GZ15391@postel.suug.ch>
	 <1117192464.6688.3.camel@localhost.localdomain>
	 <20050527121503.GN15391@postel.suug.ch>
	 <1117201853.6383.29.camel@localhost.localdomain>
	 <20050527141023.GP15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527141023.GP15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 16:10 +0200, Thomas Graf wrote:
> * jamal <1117201853.6383.29.camel@localhost.localdomain> 2005-05-27 09:50

> > In other words, if i was to draw a model diagram it would show:
> > --> netdevice 
> >   ----> v4 addresses
> >   ----> v4 netdevice configuration
> >   ----> v6 addresses
> >   ----> v6 netdevice configuration
> > 
> > i.e the best way to do it imo, especially since you are doing this from
> > scratch, is to maintain that model. Your patch breaks away from this.
> 
> I think this model is only valid for neighbour table parameter set
> and not for neighbour tables themselves.
> 

Yes, that's true. In other words, neighbor tables details are out of
scope of that model and are more appropriate to the v4/6 neighbor "box".
Anything else that is netdevice related or connected as in the above
model (as opposed to say the ARP "box" related detail) is better to
leave or add it to be part of devconfig if it doesnt exist.

To be precise there are things in your patch that are fine to leave
there; but the most it seems to me belong to the devconfig netlink path
(which doesnt exist today).

> > The only thing that is not devconfig queriable or settable at the moment
> > is the stats. That i can certainly see as being part of the standard
> > neighbor details for example. Infact this would apply elsewhere as well,
> > for example in the FIB where some stats are being displayed via /proc at
> > the moment.
> 
> This is not correct, struct ndt_config (read-only configuration, sort
> of like statistics), gc thresholds, gc interval, and the default parameter
> set are also not devconfig queriable. From a user point of view the
> most commonly changed values will be the gc thresholds, gc interval
> and parameters in the default set and if you forget about the device
> specific parameters for a second it would be pretty obvious to not put
> them into devconfig. So my point is that I don't want to put the most
> obvious and common use into something where it doesn't really fit.


The thresholds etc are there - just not netlink accessible. Example, the
default values for V4 are settable or queriable via:

/proc/sys/net/ipv4/neigh/default/gc_thresh3
/proc/sys/net/ipv4/neigh/default/gc_thresh2
/proc/sys/net/ipv4/neigh/default/gc_thresh1
/proc/sys/net/ipv4/neigh/default/gc_interval

> I do agree that the device specific parameters fit into a devconfig
> or whathever we'll call it but not the whole neighbour table
> configuration bits. 
> 

Agreed that some things are specific to the "ARP" or "NDISC" block
but not all that you have belongs to those boxes.

> > We actually did discuss this a while back and i had an incomplete patch
> > for doing it the way i suggest above which i unfortunately cant seem to
> > locate at the moment.
> 
> Can't remember to have seen such as mail or patch, do you remember
> the thread you posted this? I posted the patch 3 times and I just
> read through the archives again and can't find any such commments.

I never posted the patch unfortunately but mentioned it in the
discussions. What counts is we are having this discussion now;->

I apologize i didnt comment on the patch earlier - sometimes when i am
away from the list for sometime i skip threads which may require me to
spend time looking at them to make any useful comments. This maybe the
reason i didnt respond. To catchup i normally read emails addressed to
me first then go over the list in a LIFO mode and stop once i get
engaged in a discussion.

cheers,
jamal
