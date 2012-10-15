From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sock filter: fix copy of filter from userspace
Date: Mon, 15 Oct 2012 08:57:12 -0700
Message-ID: <20121015085712.5a70a4d0@nehalam.linuxnetplumber.net>
References: <20121013114032.2d1c1434@nehalam.linuxnetplumber.net>
	<20121013191949.GA16286@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34585 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab2JOP5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2012 11:57:54 -0400
In-Reply-To: <20121013191949.GA16286@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Oct 2012 21:19:49 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Sat, Oct 13, 2012 at 08:40:32PM CEST, shemminger@vyatta.com wrote:
> >The sk_unattached_filter_create function is passed a socket
> >filter structure and the copies the contents of the filter from
> >userspace. Sparse detected that this code was incorrectly using
> >memcpy when it needed to use copy_from_user instead.
> 
> Hmm. fprog->filter is in this case allocated and filled in kernel.
> So memcpy is good.
> 
> Not sure how to handle this correctly. Either we remove "__user" or we
> redefine "struct sock_fprog" for sk_unattached_filter_create() use.
> 
> Any thoughts?

Or define a different structure for kernel usage versus userspace API.
