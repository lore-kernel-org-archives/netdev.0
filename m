From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/2] Neighbour table prep for MPLS
Date: Wed, 4 Mar 2015 09:56:33 -0500
Message-ID: <20150304145633.GB1551@gospo>
References: <87mw3tzv8u.fsf@x220.int.ebiederm.org>
 <20150303.153310.624302583835136622.davem@davemloft.net>
 <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
 <20150304.002502.1950561993507910047.davem@davemloft.net>
 <87pp8pqpf2.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:36126 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbbCDO4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 09:56:32 -0500
Received: by qcxn11 with SMTP id n11so15513845qcx.3
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 06:56:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87pp8pqpf2.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2015 at 11:53:21PM -0600, Eric W. Biederman wrote:
> David Miller <davem@davemloft.net> writes:
> 
> > From: ebiederm@xmission.com (Eric W. Biederman)
> > Date: Tue, 03 Mar 2015 17:09:35 -0600
> >
> >> In preparation for using the IPv4 and IPv6 neighbour tables in my mpls
> >> code this patchset factors out ___neigh_lookup_noref from
> >> __ipv4_neigh_lookup_noref, __ipv6_lookup_noref and neigh_lookup.
> >> Allowing the lookup logic to be shared between the different
> >> implementations.  At what appears to be no cost. (Aka the same assembly
> >> is generated for ip6_finish_output2 and ip_finish_output2).
> >> 
> >> After that I add a simple function that takes an address family and an
> >> address consults the neighbour table and sends the packet to the
> >> appropriate location.  The address family argument decoupls callers
> >> of neigh_xmit from the addresses families the packets are sent over.
> >> (Aka The ipv6 module can be loaded after mpls and a previously
> >> configured ipv6 next hop will start working).
> >> 
> >> The refactoring in ___neigh_lookup_noref may be a bit overkill but it
> >> feels like the right thing to do.  Especially since the same code is
> >> generated.
> >
> > Series applied, thanks.
> >
> > Maybe we can make neigh_table_find() faster by making it a direct
> > array demux of some kind instead of some switch statment thing?
> > It's the only think I don't like about neigh_xmit().
> 
> We could potentially translate the numbers into the enumeration that is
> NEIGH_ARP_TABLE, NEIGH_ND_TABLE, and NEIGH_DN_TABLE.  Or waste a little
> bit of memory in have a 30 entry array and looking things up by address
> protocol number.   The only disadvantage I can see to using AF_NNN as
> the index is that it might be a little less cache friendly.
> 
> Other issues the hh header cache doesn't work. (How much do we care).
> 
> I worry a little that supporting AF_PACKET case might cause problems
> in the future.
> 
> The cumulus folks are probably going to want to use neigh_xmit so they
> can have ipv6 nexthops on ipv4.  Using this for IPv4 and loosing the
> header cache worries me a little.

Agreed, this will be good.  I had done something a bit different coming
off the the discussions at netconf, but I'll rebase to this and use it
instead.  Thanks, Eric!
