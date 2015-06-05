From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Fri, 5 Jun 2015 11:14:42 +0200
Message-ID: <20150605091441.GA11896@pox.localdomain>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37196 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbbFEJOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 05:14:46 -0400
Received: by wifx6 with SMTP id x6so13798410wif.0
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 02:14:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/15 at 07:21am, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This is still WIP and incomplete.
> Posting it here because of the other discussions
> happening around mpls ler in the context of Roberts
> code and I happened to mention this implementation.
> 
> This was in response to earlier email thread with Eric on
> net-next of possibly using xfrm style stacked destination
> approach.
> 
> I introduce a new set of tunnel ops for light weight
> tunnels (lwt), but this could be merged with the
> other ip_tunnels code if possible.
> 
> I had this code for 3.2 kernel initially, and 
> as I was pulling out code, I realize i had to separate
> out some other mpls code that i have been working on
> and quite likely this will not even compile. Sorry abt
> that.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks for posting these patches Roopa!

I see that some of the edges are still a bit rough. In particular
the lack of sanity checking around type before indexing the array
with it ;-) No question that this would make a great optimization
on top of existing IP tunnels though! I think this is where Eric
was heading to and given this implementation, I'm perfectly fine
with it as it does not *require* to precompute the headers for all
encap types.

This can be made compatible with the patches I have posted as well.
A simple flag in what you call rtencap could indicate whether to
perform the encap in the dst->output or merely attach the metadata
and forward it to RTA_OIF for postponed encapsulation.

That way, if desirable by the user, the net_device can be omitted
which would suit Eric's architecture while we still also support
the traditional net_device model which provides stats and a shared
set of encapsulation parameters. It will also allow for bridges to
perform the encapsulation decision if needed and we can still get
rid of the OVS encapsulation special handling.

As I mentioned to Robert, the new RTA_ENCAP should be a list of
Netlink attributes from the beginning to make it extendible without
ever breaking user ABI.

The most overlap seems to be with Robert's series. The direction
seems to be very similar. How do you want to proceed? Work on a
series together? I'm happy to rebase my series on top of both you
and Robert's work and make use of a new generic per nexthop
encapsulation API. Let me know how you guys want to proceed.
