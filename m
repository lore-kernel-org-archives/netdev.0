From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 net-next 1/4] net: socket: add support for async
 operations
Date: Thu, 19 Mar 2015 18:13:25 +0000
Message-ID: <20150319181325.GQ29656@ZenIV.linux.org.uk>
References: <20150316161508.16418.23674.stgit@tstruk-mobl1>
 <20150316161514.16418.67336.stgit@tstruk-mobl1>
 <20150319162024.GO29656@ZenIV.linux.org.uk>
 <550B0AB4.2060507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-aio@kvack.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ying.xue@windriver.com, bcrl@kvack.org,
	linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55546 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbbCSSNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 14:13:33 -0400
Content-Disposition: inline
In-Reply-To: <550B0AB4.2060507@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 10:43:16AM -0700, Tadeusz Struk wrote:
> On 03/19/2015 09:20 AM, Al Viro wrote:
> > is completely pointless.  Just have sock_read_iter() and sock_write_iter()
> > check if your new methods are present and use those if those are.
> > 
> 
> Ok, that will work for me too.
> 
> > What's more, I'm not at all sure that you want to pass iocb that way -
> > kernel-side msghdr isn't tied to userland one anymore, so we might as well
> > stash a pointer to iocb into it.  Voila - no new methods needed at all.
> 
> Good point, so what do you prefer - to add iocd to msghdr or to call the new
> methods from sock_read_iter() and sock_write_iter()?
> Either way is good for me.

I'd probably add msg_iocb to the end of struct msghdr and explicitly zero it in
copy_msghdr_from_user() and get_compat_msghdr(), but you are asking the wrong
guy - that sort of choices in net/* falls on davem, not me.
