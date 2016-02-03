From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Wed, 3 Feb 2016 12:59:47 -0500
Message-ID: <20160203175947.GB14627@oracle.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <20160202003127.GA25154@oracle.com>
 <CALx6S34MGwp2m=QmfQ36tWnaWbFXvMG63sj7Nz1KgMtegxn-2A@mail.gmail.com>
 <20160203173125.GA14627@oracle.com>
 <CALx6S37g57kSvvXQy2oY5uMixOw5t-Q2dRTRhGSYS0P=i-ff-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39038 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933435AbcBCSAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 13:00:01 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S37g57kSvvXQy2oY5uMixOw5t-Q2dRTRhGSYS0P=i-ff-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/03/16 09:51), Tom Herbert wrote:
> > (a) quite noisy
> 
> Try disabling the crash dump. That will improve performance.

huh?? 

there is no crash dump involved. If you meant "disable dump_stack()"
sure, I am aware of that, and that is the default behavior of 
log_unaligned(). I was just trying to be helpful and provide
stack traces (I dropped out quite a few, which come from mld, 
ip_fast_csum() etc, which log_unaligned rate-limits and suppresses
by default, btw)

(Removing the batteries from my fire-alarm doesnt make the fire 
go away :-))

> But as we said it's only for tunnels that specifically encapsulate an
> ethernet header with aligning it. Many other encapsulations (e.g.
> IPIP, GUE, EtherIP,IP/GRE) should be fine. We could take this to IETF
> and point out that alignment is still relevant in protocol
> development. We can't fix this for GRE or VXLAN at this point, but
> maybe there's still hope for VXLAN-GPE or Geneve...

good point about taking to ietf, but the list above is not accurate.
IP/GRE itself generated a few log_unaligned() warnings for me, I'd
have to sift through it carefully - need some time for that.. 

> Right, but there is a big difference between a performance degradation
> and a hard failure. It would at least be nice to know what the
> performance hit actually is, if it's acceptable then this would be a
> far simpler and much less invasive fix than the alternatives.

--Sowmini
