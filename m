From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 04 Sep 2012 12:31:15 -0700
Message-ID: <87a9x537r0.fsf@xmission.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	<1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
	<87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com>
	<CAJZOPZ+ZHBg=vswgmWWz2D0GyWhD-ghkuY9_7CQB47uDmyzhsA@mail.gmail.com>
	<20120903212230.GA6795@redhat.com>
	<CAJZOPZJdmDY8rqHJ+jeuG2rLMj9CnwnemkBG=nxD=z9JBFQCRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>,
	Ali Ayoub <ali@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:40641 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757663Ab2IDTb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 15:31:27 -0400
In-Reply-To: <CAJZOPZJdmDY8rqHJ+jeuG2rLMj9CnwnemkBG=nxD=z9JBFQCRQ@mail.gmail.com>
	(Or Gerlitz's message of "Tue, 4 Sep 2012 21:50:09 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <or.gerlitz@gmail.com> writes:

> On Tue, Sep 4, 2012 at 12:22 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> On Mon, Sep 03, 2012 at 11:53:56PM +0300, Or Gerlitz wrote:
>
>>> So we are remained with #3 - the ARPs -- thinking on this a little
>>> further, FWIW there --are-- components in the kernel which
>>> mangle/generate ARPs and are exposing netdevice, such as openvswitch, anyway:
>
>>> does it make sense to forward ARPs received into / sent over the
>>> eIPoIB netdevice (e.g using some sort of rule) to some outer entity
>>> such as user-space daemon  for interception and later re-injection into eIPoIB?
>
>> Well if this is all you want to do, you can bind a packet socket to the
>> interface, and drop them at the nic.  It is harder to do for incoming
>> ARP requests though.
>
>> I would do something else: send ARPs out to some defined IB address.
>> This could be local host or queries from some SA property.  Said remote
>> side could send you the responses in ethernet format so you do not need
>> to mangle responses at all.  Similarly for incoming ARP requests.
>
>> The rule to do this can also just redirect non IP packets - this is IPoIB after all.
>
> Thanks for the heads up on the possible implementation route, will
> look into that.
>
>>> Documentation we will fix,
>
>> And just to stress the point, document the limitations as well.
>
> sure, not that I see concrete limitations for the **user** at this point, but
> if there are such, will put them clearly written.

So far you are still playing with a design that is strongly NOT
ethernet.  So calling it eIPoIB will continue to be a LIE.

You are still playing with an implementation that doesn't even dream
of supporting IPv6 which makes it so far from ethernet I can't imagine
anyone taking your code seriously.

All ethernet protocols not working except IPv4 is a huge concrete
limitation.

Any implementation that breaks a naive ARP implementation also breaks
IPv6.  Not to mention everything else that runs over ethernet.

If you are clever you can use the current IPoIB hardware accelleration
but you need to do something different so that you can either encode
or imply the MAC address so you won't have to munge ethernet protocols.

Just for fun you might want to consider what it takes to support 2 VMs
in the same VLAN that share the same IP address (but different MAC
addresses) for failover purposes.

Eric
