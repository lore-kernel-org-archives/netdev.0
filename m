From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 2/2][RFC] virtio_net: Add MAC fitler table support
Date: Sat, 10 Jan 2009 13:41:28 -0600
Message-ID: <4968F9E8.40005@codemonkey.ws>
References: <1231351563.7109.130.camel@lappy>	 <200901102148.54962.rusty@rustcorp.com.au> <4968E669.8040707@codemonkey.ws> <1231613431.9095.20.camel@bling>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:29880 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbZAJTkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 14:40:07 -0500
In-Reply-To: <1231613431.9095.20.camel@bling>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Williamson wrote:
> Hmm, that's not quite how I was implementing it.  The uc_list and
> mc_list are stored up in the netdev level, so there's not much point in
> duplicating it in the guest virtio-net driver.  The interface I was
> working on has two commands.  The first tells the host to allocate the
> MAC filter table for a guest provided number of entries (perhaps a
> module parameter, with reasonable default).  The other is a set command
> with an sg entry providing a buffer of all the MAC entries for the
> table.  If sg entries are no more than a page, this limits us to ~680
> MAC table entries, which I think is far more than any piece of real
> hardware (and large enough that you'd probably want to turn on
> promiscuous already).

Yeah, this is what I would have done although maybe it's worth allowing 
a partial update of the filter table.  Once you're using a command 
interface, a protocol like you describe makes sense.  I was simply going 
the through the logic that led me to suggest a command interface in the 
first place.

>   The VLAN equivalent is a bit easier since by
> definition there are 4k possible VLANs.  There I think a set bit/clear
> bit message interface is appropriate (and maybe a clear all for a reset
> condition).  Let me know if that sounds reasonable.  Thanks,
>   

Yeah, sounds reasonable to me.

Regards,

Anthony Liguori

> Alex
>
>   

