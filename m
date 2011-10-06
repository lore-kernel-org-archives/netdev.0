From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Thu, 6 Oct 2011 09:23:53 -0400
Message-ID: <20111006132353.GF2479@zod.bos.redhat.com>
References: <20111005202723.GE2479@zod.bos.redhat.com>
 <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>, Joel Sing <jsing@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64718 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964855Ab1JFNYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 09:24:08 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 06, 2011 at 12:18:44AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 5 Oct 2011, Josh Boyer wrote:
> 
> > Hi All,
> > 
> > We've had a report [1] of a change in behavior when trying to use an IP
> > alias to tftp from a loopback device.  Apparently the steps outlined in
> > the bug worked in 2.6.35, and broke somewhere before 2.6.38.6.
> > 
> > I can confirm the steps fail on a 3.0 based kernel and I'm trying to do
> > a git bisect to find the commit involved, but I thought I would send
> > this along to see if anyone might have an idea.  (Also, I'm not really
> > sure how valid of a usecase this was to begin with.)
> 
> 	What about commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c ?
> 
> ipv4/route.c: respect prefsrc for local routes
> 
> http://marc.info/?t=129412232500001&r=1&w=2
> 
> > [1] https://bugzilla.redhat.com/show_bug.cgi?id=739534

Yep.  That is exactly what my git bisect said too.

So now we have a change in behavior since that commit for the usecase
described in the bug above, but I'm unsure if that usecase was ever
really valid or if the commit had unintentional side effects.

Joel (or anyone else) can you take a look and comment?

josh
