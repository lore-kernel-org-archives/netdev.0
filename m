From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 4 Sep 2012 21:50:09 +0300
Message-ID: <CAJZOPZJdmDY8rqHJ+jeuG2rLMj9CnwnemkBG=nxD=z9JBFQCRQ@mail.gmail.com>
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
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56530 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216Ab2IDSuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 14:50:11 -0400
Received: by iahk25 with SMTP id k25so5942395iah.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 11:50:10 -0700 (PDT)
In-Reply-To: <20120903212230.GA6795@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 4, 2012 at 12:22 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, Sep 03, 2012 at 11:53:56PM +0300, Or Gerlitz wrote:

>> So we are remained with #3 - the ARPs -- thinking on this a little
>> further, FWIW there --are-- components in the kernel which
>> mangle/generate ARPs and are exposing netdevice, such as openvswitch, anyway:

>> does it make sense to forward ARPs received into / sent over the
>> eIPoIB netdevice (e.g using some sort of rule) to some outer entity
>> such as user-space daemon  for interception and later re-injection into eIPoIB?

> Well if this is all you want to do, you can bind a packet socket to the
> interface, and drop them at the nic.  It is harder to do for incoming
> ARP requests though.

> I would do something else: send ARPs out to some defined IB address.
> This could be local host or queries from some SA property.  Said remote
> side could send you the responses in ethernet format so you do not need
> to mangle responses at all.  Similarly for incoming ARP requests.

> The rule to do this can also just redirect non IP packets - this is IPoIB after all.

Thanks for the heads up on the possible implementation route, will
look into that.

>> Documentation we will fix,

> And just to stress the point, document the limitations as well.

sure, not that I see concrete limitations for the **user** at this point, but
if there are such, will put them clearly written.

Or.
