From: Huw Davies <huw@codeweavers.com>
Subject: Re: [RFC PATCH 16/17] calipso: Add validation of CALIPSO option.
Date: Tue, 22 Dec 2015 22:29:22 +0000
Message-ID: <20151222222921.GA30207@merlot>
References: <1450784813-18304-17-git-send-email-huw@codeweavers.com>
 <5679551C.4000105@stressinduktion.org>
 <20151222165919.GA31791@merlot>
 <5679C4FF.4050505@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Paul Moore <pmoore@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:41664 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbbLVW31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 17:29:27 -0500
Content-Disposition: inline
In-Reply-To: <5679C4FF.4050505@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 10:47:43PM +0100, Hannes Frederic Sowa wrote:
> On 22.12.2015 17:59, Huw Davies wrote:
> > I'm confused about this one.  AFAICS, this will drop packets that we
> > can't process.  We don't send the icmp error, but I can certainly add
> > that.  Is that what you mean?
> 
> Actually, the implementation of calipso_validate will accept the packets
> because it defaults to return true if we don't compile the module. At
> least we should drop the packet if it is not loaded. I am in favor of
> adding the parameter problem icmp error. So, yes, I think it should be
> added.

Yet the option value is 0x07, i.e. the two highest bits are both zero
which according to:
https://tools.ietf.org/html/rfc2460#section-4.2
means we should just skip it.

https://tools.ietf.org/html/rfc5570#section-5.1.1
reaffirms that.

In terms of sending an icmp on error while validating:
https://tools.ietf.org/html/rfc5570#section-6.2.2
is pretty conservative in that case too.  Most errors
should just be silently dropped.

Huw.
