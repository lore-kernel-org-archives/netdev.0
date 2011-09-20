From: Dan Williams <dcbw@redhat.com>
Subject: Re: bridge carrier issue
Date: Tue, 20 Sep 2011 16:12:39 -0500
Message-ID: <1316553160.1783.112.camel@dcbw.foobar.com>
References: <20110920.152953.448244771460257273.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab1ITVMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 17:12:38 -0400
In-Reply-To: <20110920.152953.448244771460257273.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-20 at 15:29 -0400, David Miller wrote:
> I'm marking the patches in patchwork on this as "deferred".
> 
> It is my opinion that we need to push back on the virtualization stuff
> because otherwise it is impossible for network manager and friends to
> operate properly.
> 
> Without the carrier going on only when a device is actually attached
> and operating, NM has no "signal" to know when it actually should do
> DHCP and whatnot.

There's stuff we're planning for NM that'll make it much more friendly
to these use-cases, but that's mostly *after* the interface is
configured and running.  What the semantics of the bring-up behavior
should be need more discussion.  ie, in the case we're talking about
here, NM wouldn't even apply a static IP configuration to the bridge
until the bridge said it was up.  That's something we can change with a
flag in the bridge's config.

Dan

> On the other hand, the virtualization tools and libraries can operate
> properly within the constraints added by the carrier behavior we have
> now.
> 
> And I also believe they can do so in a way that allows them to work
> on kernels before the carrier change.
> 
> Therefore, the only way to move forward and get everything working is
> to change the virtualization tools.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
