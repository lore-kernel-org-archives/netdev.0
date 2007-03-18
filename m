From: Dan Aloni <da-x@monatomic.org>
Subject: Re: [PATCH] tcp_sendpage(): fix broken page iteration
Date: Mon, 19 Mar 2007 00:40:10 +0200
Message-ID: <20070318224009.GA15407@localdomain>
References: <20070318124346.GA6396@localdomain> <20070318.144927.78708843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from noname.neutralserver.com ([70.84.186.210]:51456 "EHLO
	noname.neutralserver.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S933217AbXCRWkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 18:40:17 -0400
Content-Disposition: inline
In-Reply-To: <20070318.144927.78708843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 18, 2007 at 02:49:27PM -0700, David Miller wrote:
> From: Dan Aloni <da-x@monatomic.org>
> Date: Sun, 18 Mar 2007 14:43:46 +0200
> 
> > do_tcp_sendpages() should not iterate 'pages' as an array since 
> > it is not an array of 'struct page *', but a pointer to a single 
> > entity of 'struct page *' passed on the stack as a parameter to 
> > tcp_send_page() (hence it would crash if poffset + psize > PAGE_SIZE,
> > because pages[1] and beyond most probably not constitutes a valid 
> > 'struct page *').
> 
> do_tcp_sendpages() should never get passed poffset+psize>PAGE_SIZE,
> that would be a bug.

Oh, then the name of that function was quite misleading...

Anyway, I thought it would make a valid case for a situation where
you have a kmalloc'ed buffer that happens to cross a page boundery 
and you want to call ->sendpage() to send it over using network
DMA. 

As I see it, with this constraint you either call sendpage twice or
you use kernel_sendmsg(), I am not sure which would me more 
efficient - I guess it depends on psize. I wish there was a better
interface than sendpage that would have factored it in...

Thanks anyway for the heads up.

-- 
Dan Aloni
XIV LTD, http://www.xivstorage.com
da-x (at) monatomic.org, dan (at) xiv.co.il
