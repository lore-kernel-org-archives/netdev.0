From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] cipso: handle CIPSO options correctly when NetLabel is disabled
Date: Fri, 01 Jun 2012 09:14:19 -0400
Message-ID: <1458832.5C3jQy5BFx@sifl>
References: <20120531200922.6265.81763.stgit@sifl> <20120531.190705.3612500429295140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759622Ab2FANOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2012 09:14:44 -0400
In-Reply-To: <20120531.190705.3612500429295140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, May 31, 2012 07:07:05 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Thu, 31 May 2012 16:09:23 -0400
> 
> > When NetLabel is not enabled, e.g. CONFIG_NETLABEL=n, and the system
> > receives a CIPSO tagged packet it is dropped (cipso_v4_validate()
> > returns non-zero).  In most cases this is the correct and desired
> > behavior, however, in the case where we are simply forwarding the
> > traffic, e.g. acting as a network bridge, this becomes a problem.
> > 
> > This patch fixes the forwarding problem by providing the basic CIPSO
> > validation code directly in ip_options_compile() without the need for
> > the NetLabel or CIPSO code.  The new validation code can not perform
> > any of the CIPSO option label/value verification that
> > cipso_v4_validate() does, but it can verify the basic CIPSO option
> > format.
> > 
> > The behavior when NetLabel is enabled is unchanged.
> > 
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> I don't like this at all.
> 
> The only conclusion I can come to is that cipso_v4_validate() is doing
> the wrong thing when NETLABEL is disabled.
> 
> There is never a good reason to crap all over a function with ifdefs.
> This is especially true when it's being done to paper over a function
> with poor semantics.
> 
> The whole idea is to abstract and put all of this kind of logic into
> cipso_v4_validate().

I originally had the #ifdef'd code in the non-CONFIG_NETLABEL 
cipso_v4_validate() in include/net/cipso_ipv4.h but thought it was too much 
code to put there.  No worries, I'll just move it back and resubmit.

-- 
paul moore
security and virtualization @ redhat
