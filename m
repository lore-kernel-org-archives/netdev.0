From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 4 Sep 2012 22:47:42 +0300
Message-ID: <CAJZOPZKq-EBUq+8xb0Oxs+zwNS9DkFdx_8n8+-WkPyWfPkOn-Q@mail.gmail.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	<1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
	<87boitz044.fsf@xmission.com>
	<20120805185031.GA18640@redhat.com>
	<CAJZOPZ+ZHBg=vswgmWWz2D0GyWhD-ghkuY9_7CQB47uDmyzhsA@mail.gmail.com>
	<20120903212230.GA6795@redhat.com>
	<CAJZOPZJdmDY8rqHJ+jeuG2rLMj9CnwnemkBG=nxD=z9JBFQCRQ@mail.gmail.com>
	<87a9x537r0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>,
	Ali Ayoub <ali@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65362 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757729Ab2IDTrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 15:47:42 -0400
Received: by iahk25 with SMTP id k25so6059475iah.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 12:47:42 -0700 (PDT)
In-Reply-To: <87a9x537r0.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 4, 2012 at 10:31 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Or Gerlitz <or.gerlitz@gmail.com> writes:
>> On Tue, Sep 4, 2012 at 12:22 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>>>> Documentation we will fix,
>>> And just to stress the point, document the limitations as well.
>> sure, not that I see concrete limitations for the **user** at this point, but
>> if there are such, will put them clearly written.

> All ethernet protocols not working except IPv4 is a huge concrete limitation.

Oh, sure, that WILL be documented, currently eIPoIB can deliver only what
IPoIB can which is IPv4, ARP/RARP, IPv6+ND, for IPv6 see next

> So far you are still playing with a design that is strongly NOT
> ethernet.  So calling it eIPoIB will continue to be a LIE.

> You are still playing with an implementation that doesn't even dream
> of supporting IPv6 which makes it so far from ethernet I can't imagine
> anyone taking your code seriously.

This design can and will support IPv6, the IPv6 ND handling will follow the path
we are talking now for the IPv4 ARPs, e.g not within the driver, etc.
Could you be
more specific?

> Any implementation that breaks a naive ARP implementation also breaks
> IPv6.  Not to mention everything else that runs over ethernet.

not sure to follow on the naive impl. comment,  eIPoIB solution will
include kernel driver along with supporting user-space portion, this
is to follow a comment made by the community on mangling ARPs in
network driver.

> If you are clever you can use the current IPoIB hardware accelleration
> but you need to do something different so that you can either encode
> or imply the MAC address so you won't have to munge ethernet protocols.

also here not sure to follow, we have a new design under which the
original VM MAC is preserved on the RX side, we will not generate MAC
for Ethernet frames sent by VMs which we reconstruct on the RX side
any more.

> Just for fun you might want to consider what it takes to support 2 VMs
> in the same VLAN that share the same IP address (but different MAC
> addresses) for failover purposes.

will look on that

Or.
