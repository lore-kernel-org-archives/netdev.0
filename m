From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 30 Aug 2004 21:43:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093916592.1037.51.camel@jzny.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
	 <20040830144033.2265a6e6.davem@redhat.com>
	 <1093904088.1043.12.camel@jzny.localdomain>
	 <20040830154430.769d1d59.davem@redhat.com>
	 <1093906592.1037.32.camel@jzny.localdomain>
	 <20040830160052.548c4846.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040830160052.548c4846.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-30 at 19:00, David S. Miller wrote:
> On 30 Aug 2004 18:56:32 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > Sounds reasonable to me. Some of the BSDs do this to maintain old compat
> > - just means keeping old struct around. Steve, agreeable to you? 
> > 
> > Change to both kernel and user space or just user space?
> 
> But this takes care of 'tc' only.  What about other programs
> grabbing TC_STATS?  The whole world of netlink is not the
> iproute2 tree.

Agreed. Note, however the only time it wont work was case for

4) old kernel +  new tc --> will bomb (sizeof check will fail)

s/tc/randomnetlinkapp

i.e old apps will continue to work.
We could probably impose some rules like the code you posted.
I actually only see reason to keep old_tc_stats in user space only. New
apps wanting to support old structures must copy them.

> Maybe instead we should create TC_STATS2?  That's a lot of
> work just to add this one new statistic, I must say.

That too - it will mean keeping both old and new in user space and
kernel. It is from an ABI perspective cleaner than the first one.
Not sure if it is worth for this one element in a structure.
Theres also already the *_XSTAS which is supposed to be a speacial non
generic stat that could be used to transport the requeue it just seems
to be such a waste to use it for transporting a sinle 32 bit value
(which just happens to be generic for qdiscs). It would also involve
more code overall.

One of these days i will code the discovery thoughts i have been having.
Just ask the kernel what it has and we are set.

On Mon, 2004-08-30 at 19:05, Stephen Hemminger wrote: 

> I have no problem but easier to just do something:
> 	struct tc_stats mystats;
> 
> 	memset(&mystats, 0, sizeof(mystats));
> 	memcpy(&mystats, RTA_DATA(tb[TCA_STATS]), RTA_PAYLOAD(tb[TCA_STATS]));
> 
> that way it can grow as much as we want and don't have v1, v2, v3, ... 
> size structures.

Not sure i parsed that. You mean the tc_stats in user space will be the new 
one.

cheers,
jamal
