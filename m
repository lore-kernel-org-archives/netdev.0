From: Catalin BOIE <util@deuroconsult.ro>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Wed, 7 Jul 2004 10:01:30 +0300 (EEST)
Sender: lartc-admin@mailman.ds9a.nl
Message-ID: <Pine.LNX.4.60.0407070957070.2496@hosting.rdsbv.ro>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
 <20040702134437.5891e998@dell_ss3.pdx.osdl.net>  <1088824432.1043.271.camel@jzny.localdomain>
  <20040706090906.4ff6fb73@dell_ss3.pdx.osdl.net> <1089164179.1039.26.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1089164179.1039.26.camel@jzny.localdomain>
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

On Wed, 6 Jul 2004, jamal wrote:

> On Tue, 2004-07-06 at 12:09, Stephen Hemminger wrote:
>
>> Your examples made me think about this more.  The netfilter seem best
>> suited to things that effect the flow of packets (dropping, reordering,
>> even corrupting), and the qdisc seems best when the timing needs to change.
>
> Some of the attributes you are trying to control need queueing; no doubt
> the best spot to do queueing is on a qdisc. Delays, and reordering for
> example are ideal. Rate control as well fits here. There are other
> qdiscs which have done a really good job at rate control hence my
> arguement against you doing it - you will either not do a better job at
> it or if you do a good job you will be replicating what they already
> did; just stash your qdisc in another qdisc which can do a good rate
> control job (CBQ, TBF, HFSC, HTB) - we are flexible enough in Linux.
>
> Depending on where you want to do things, netfilter may be a good
> candidate (example IP protocol) or things that dont need queueing.
> The examples i gave are more powerful than anything netfilter can do at
> the moment though with only caveat theres only two "hooks".
>
>> The limit match in netfilter is not the same as the rate in the qdisc.
>> The netem scheduler acts as if the link is a slow fixed rate.  The netfilter
>> limit is usually targeted to drop packets over the rate which is not the same.
>> Reordering is also hard without going out to a user log or building a custom
>> target.
>
> Not sure what the netfilter limit target is - i suspect its something
> that limits based on a group of flows. You can still do that with a
> fwamrk at the qdisc level. Reordering needs a queue. Even the example i
> gave uses a queue that resides on the dummy device.
>
>> So, you have convinced me that loss is unnecessary but not the rate, or delay.
>> If we can figure out how to re-ordering with netfilter then that could go too,
>> which would make it possible to use a layered qdisc again.
>
> I think keep the reordering aspect of it unless it is very complex. The
> delay is a must. If you can add configurable jitter to it that would be
> a big bonus. Keep the randomization.  Duplication, dropping, bit error
> injection, and rate control are the ones i didnt see belonging there
> mostly because they can be done better elsewhere.
> Again this is just opinion, if you think that theres no complexity in
> the architecture, by all means keep all those features - my
> recommendation is to pick a few things that will work well and implement
> them well.
>
> cheers,
> jamal

I suggest to keep duplication because:
1. Adds 5-10 lines of code and no complexity
2. It's very easy to use it attached directly to a device.

Thank you.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
