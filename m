From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 4 Sep 2012 21:57:01 +0300
Message-ID: <CAJZOPZL+hAQR_7MUGy9kLCzoLY7hbDwEGGodiMxc=yfPgmi8bQ@mail.gmail.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	<1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
	<87boitz044.fsf@xmission.com>
	<20120805185031.GA18640@redhat.com>
	<CAJZOPZ+ZHBg=vswgmWWz2D0GyWhD-ghkuY9_7CQB47uDmyzhsA@mail.gmail.com>
	<20120903212230.GA6795@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>,
	Ali Ayoub <ali@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:52986 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757486Ab2IDS5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 14:57:02 -0400
Received: by ieje11 with SMTP id e11so5707815iej.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 11:57:01 -0700 (PDT)
In-Reply-To: <20120903212230.GA6795@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 4, 2012 at 12:22 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, Sep 03, 2012 at 11:53:56PM +0300, Or Gerlitz wrote:
>> Michael S. Tsirkin <mst@redhat.com> wrote:
>> > [...] so it seems that a sane solution would involve an extra level of
>> > indirection, with guest addresses being translated to host IB addresses.
>> > As long as you do this, maybe using an ethernet frame format makes sense.
>>
>> > So far the things that make sense. Here are some that don't, to me:
>>
>> > - Is a pdf presentation all you have in terms of documentation?
>> >   We are talking communication protocols here - I would expect a
>> >   proper spec, and some effort to standardize, otherwise where's the
>> >   guarantee it won't change in an incompatible way?
>> >   Other things that I would expect to be addressed in such a spec is
>> >   interaction with other IPoIB features, such as connected
>> >   mode, checksum offloading etc, and IB features such as multipath etc.
>> >
>> > - The way you encode LID/QPN in the MAC seems questionable. IIRC there's
>> >   more to IB addressing than just the LID.  Since everyone on the subnet
>> >   need access to this translation, I think it makes sense to store it in
>> >   the SM. I think this would also obviate some IPv4 specific hacks in kernel.
>>
>> > - IGMP/MAC snooping in a driver is just too hairy.
>> >   As you point out, bridge currently needs the uplink in promisc mode.
>> >   I don't think a driver should work around that limitation.
>> >   For some setups, it might be interesting to remove the promisc
>> >  mode requirement, failing that, I think you could use macvtap passthrough.
>> >
>> > - Currently migration works without host kernel help, would be
>> >   preferable to keep it that way.

>> If we rewind to this point, basically, you had few concerns

> I think some other people gave feedback too, you need to address it in
> the patch (as opposed to by mail - even if it's in documentation or
> comments) don't just focus on what I wrote.

The other feedback was:

1. suggesting to introduce new link layer for the para-virtualized
network stack, a direction pointed by Dave and you, for which  I
responded that it doesn't address a hard requirement I got, which is
provide service  to an arbitrary VM which have any OS and a virtual
Ethernet NIC on, emulated or para-virtualized.

2. Suggestions to use solutions which involve routing and/or
proxt-arp, for which I responded that in most/practical cases this
will require for the host to know the VM IP, something which isn't
valid assumption in many cases AND that bunch of cloud stacks,
specifically the leading ones, don't even support that option, which
also violates a hard requirement we got, to support these stacks which
are in use by customers.

3. Suggestions to invent EoIB -- I said, OK but this is long termish
process that we're looking on, might be around at some future point,
but still we are required to support whole echo systems which use
IPoIB, and there's no point to "route" between EoIB segment to IPoIB
segments, its back to #2 which we didn't accept

4. Other feedback saying the eIPoIB driver is messy and "we don't like
it" -- hard to exactly address in code changes

----> all in all, we were suggested few directions which don't allow
us to address  the problem statement, so there's no way to change the
code so they are fullfilled, and some not concrete comments which are
also hard to address --> we took the route of design changes along
your **concrete** comments, doesn't it make sense?

Or.
