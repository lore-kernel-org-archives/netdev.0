From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Fri, 27 May 2005 09:50:53 -0400
Message-ID: <1117201853.6383.29.camel@localhost.localdomain>
References: <20050526185306.GW15391@postel.suug.ch>
	 <20050526185526.GZ15391@postel.suug.ch>
	 <1117192464.6688.3.camel@localhost.localdomain>
	 <20050527121503.GN15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527121503.GN15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 14:15 +0200, Thomas Graf wrote:
> * jamal <1117192464.6688.3.camel@localhost.localdomain> 2005-05-27 07:14
> > It would have been better, IMO, to just work on a generic idev/devinet
> > retrieval and setting instead of one component (as in ARP in this
> > case). 
> 
> I thought about adding a devinet component to allow retrieving/setting
> device specific parameters (along with other settings) but dropped the
> idea because I did not want to implement the data structures twice.
>
> I think this is cleaner, it allows one request to be sent to see
> the complete arp/ndisc configuration rather than sending one to
> retrieve the global configuration/statistics and another one
> to retrieve device specific parameters.
> 
> Nevertheless, I'm open for changes so once I've written the devinet
> component to change rp_filter, forwarding, arp_filter, etc. we can
> still move the device specific NDTA_PARMS to the devinet component
> if we still think it would be better. For now, the neightbl component
> is clean, small, well defined and probably never needs to be touched
> again.
> 
> Is that acceptable for you?
> 


I think depends on where we are going. My view is that the current
abstraction model is fine for this specific bit.

i.e from an abstraction point of view these parameters are per device
per protocol (v4/v6/etc). 

In other words, if i was to draw a model diagram it would show:
--> netdevice 
  ----> v4 addresses
  ----> v4 netdevice configuration
  ----> v6 addresses
  ----> v6 netdevice configuration

i.e the best way to do it imo, especially since you are doing this from
scratch, is to maintain that model. Your patch breaks away from this.
The only thing that is not devconfig queriable or settable at the moment
is the stats. That i can certainly see as being part of the standard
neighbor details for example. Infact this would apply elsewhere as well,
for example in the FIB where some stats are being displayed via /proc at
the moment.

We actually did discuss this a while back and i had an incomplete patch
for doing it the way i suggest above which i unfortunately cant seem to
locate at the moment. 

cheers,
jamal
