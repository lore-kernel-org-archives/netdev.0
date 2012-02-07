From: David Miller <davem@davemloft.net>
Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround around
 the skb buff size issue
Date: Tue, 07 Feb 2012 13:32:08 -0500 (EST)
Message-ID: <20120207.133208.1817158606072906259.davem@davemloft.net>
References: <1328572230.12637.18.camel@deadeye>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F81413@ORSMSX106.amr.corp.intel.com>
	<1328639192.3549.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, steweg@ynet.sk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328639192.3549.14.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 7 Feb 2012 18:26:32 +0000

> On Tue, 2012-02-07 at 00:13 +0000, Rose, Gregory V wrote:
>> > -----Original Message-----
>> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>> > Sent: Monday, February 06, 2012 3:51 PM
>> > To: Rose, Gregory V
>> > Cc: David Miller; steweg@ynet.sk; linux-kernel@vger.kernel.org;
>> > netdev@vger.kernel.org
>> > Subject: RE: [patch v1, kernel version 3.2.1] rtnetlink workaround around
>> > the skb buff size issue
>> > 
>> > On Mon, 2012-02-06 at 04:41 +0000, Rose, Gregory V wrote:
>> > [...]
>> > > > This is not how we're going to fix this.  I already stated the desired
>> > > > way to fix this, which is to make the existing dump request have a way
>> > > > for the requestor to enable extended parts of the device dump.
>> > > >
>> > > > This is just like netlink diag socket dumps, where the dump request
>> > > > specifies what the user wants to see.
>> > > >
>> > > > In this case we'd add a netlink attribute to the dump request which
>> > > > is just a u32 bitmask or similar.
>> > > >
>> > > > The Intel engineer who added the VF dump support said he would work on
>> > > > this fix so why don't you just wait patiently for him to do the work?
>> > >
>> > > The patch below is what I've got so far.  Right now the bit mask array
>> > > is global so if you enable display of VF (n) on one interface it will
>> > > enable display of the same VF on other interfaces.  I intend to move
>> > > the bit mask array into the net_device structure so we can set the
>> > > display mask for each interface independently.
>> > 
>> > I don't think this can work.  Using an application that requests VF
>> > information and uses large buffers (e.g. the updated 'ip') will break
>> > another application that doesn't (e.g. current Network Manager), won't
>> > it?
>> 
>> It's my understanding that the problem isn't with the application
>> buffer size but with the kernel buffer size, which is limited to a
>> page.
> [...]
> 
> Then it's no wonder you're going about this the wrong way.

It is the userland buffer size that is the problem, userland will allocate
max(8192, PAGE_SIZE) for it's recvmsg() call, that's why we have to only
dump VF's and other potentially large objects when the user enables it in
the request.
