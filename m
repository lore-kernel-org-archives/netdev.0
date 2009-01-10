From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 2/2][RFC] virtio_net: Add MAC fitler table support
Date: Sat, 10 Jan 2009 11:50:31 -0700
Message-ID: <1231613431.9095.20.camel@bling>
References: <1231351563.7109.130.camel@lappy>
	 <200901102148.54962.rusty@rustcorp.com.au> <4968E669.8040707@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4968E669.8040707@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-01-10 at 12:18 -0600, Anthony Liguori wrote:
> Ideally, you'd have an area of guest memory sized by the guest (so there 
> was no intrinsic limit on table size) that was given to the host to use 
> as the filter tables.  The only way this works with virtio is if you 
> send this over a virtqueue in the form of messages.  You could write a 
> pfn to the config space but then you lose all the mapping/unmapping 
> abstraction that virtqueue gives you (even though we don't do anything 
> useful with that abstraction today :-)).

Hmm, that's not quite how I was implementing it.  The uc_list and
mc_list are stored up in the netdev level, so there's not much point in
duplicating it in the guest virtio-net driver.  The interface I was
working on has two commands.  The first tells the host to allocate the
MAC filter table for a guest provided number of entries (perhaps a
module parameter, with reasonable default).  The other is a set command
with an sg entry providing a buffer of all the MAC entries for the
table.  If sg entries are no more than a page, this limits us to ~680
MAC table entries, which I think is far more than any piece of real
hardware (and large enough that you'd probably want to turn on
promiscuous already).  The VLAN equivalent is a bit easier since by
definition there are 4k possible VLANs.  There I think a set bit/clear
bit message interface is appropriate (and maybe a clear all for a reset
condition).  Let me know if that sounds reasonable.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

