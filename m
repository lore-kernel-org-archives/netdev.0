From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Fri, 15 Jan 2010 10:19:14 -0500
Message-ID: <1263568754.23480.142.camel@bigi>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	 <4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	 <4B50403A.6010507@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B50403A.6010507@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-01-15 at 11:15 +0100, Patrick McHardy wrote:
> jamal wrote:

> > b) dynamic protocols (routing, IKE etc): how do you do that without 
> > making both sides understand what is going on?
> 
> In case of IPsec the outer addresses are different, its only the
> selectors which will have similar addresses. A keying deamon should
> have no trouble with this. The ifindex would be needed in the
> selectors though to make sure each policy is used for the correct
> traffic.

you need to have user space knowledgeable of the mapping between an
ifindex and a zone. It may work with perhaps that info explicitly in
config with tunnel mode/ESP.

> A routing daemon is unrealistic to be used in this scenario, at
> least a single one for all the overlapping networks.

I think in general, it would be hard to deal with anything that requires
dynamic control where one or more peers have to discover each other once
you have IP overlap. You will have to change those user space apps.

In any case, for what you seem to intend this for, i think it works.

> > Agreed. But the major ones like iproute2 etc could be taught. We have
> > namespaces in the kernel already, over a period of time I think changing
> > the user space tools would a sensible evolution.
> 
> Yes, that might be useful in any case. But I don't think it would
> even work for iproute or other standalone programs, a process can't
> associate to an existing namespace except through clone(). So it
> needs to run as child of a process already associated with the
> namespace.

The mechanics are not there, yet. But if i had sufficient permission,
and was able to find the namespaces when i ask and/or get events when it
is created it should be an issue of sending it a message.
The current approach to say migrate a veth via iproute2 requires we 
know the pid of the target namespace. Thats a usability issue.
I tried to muck with namespaces and if you use a library like lxc
you can do it - but it is a hack as it stands today (and merging
iproute2 with lxc is questionable).


>  (X + 152) bytes,
> > correct?
> > What is the typical sizeof X?
> 
> No, to give some correct number. Assuming a conntrack table of
> 10MB (large, but reasonable depending on the number of connections)
> we get an overhead of:
> 
> namespaces: 150 * 10MB memory use
> "zones": 152 bytes increased code size

That is substantial if you are doing an embedded device.
But otherwise, RAM is so cheap that i would take usability
any day for an extra $5.

BTW, I think the zones approach will still use more than 10MB
in this case given it encompasses all "zones" whereas namespace only
does it for a single mapped "zone".

> Both approaches additionally need one extra connection tracking
> entry of ~300 bytes per connection that is actually handled twice.

Ok, so computation is not a differentiator.

> That will go away once I add a target for classification. 

Makes sense 
On a side note: I wouldnt mind seeing some field in struct
netdev for some general purpose grouping/IDing which could be
set from user space. 

cheers,
jamal



