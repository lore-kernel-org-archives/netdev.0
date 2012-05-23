From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] if: restore token ring ARP type to header
Date: Tue, 22 May 2012 19:34:30 -0700
Message-ID: <20120522193430.095dcfb8@s6510.linuxnetplumber.net>
References: <20120522140105.284c28cd@nehalam.linuxnetplumber.net>
	<CAP=VYLqMGeFvy8O_zLi+sEP0t6p5M8f_x7d0g1XGkLHdVUVzUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45323 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753929Ab2EWCeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 22:34:36 -0400
In-Reply-To: <CAP=VYLqMGeFvy8O_zLi+sEP0t6p5M8f_x7d0g1XGkLHdVUVzUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 May 2012 22:28:28 -0400
Paul Gortmaker <paul.gortmaker@windriver.com> wrote:

> On Tue, May 22, 2012 at 5:01 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > Recent removal of Token Ring breaks the build of iproute2.
> >
> > Even though Token Ring support is gone from the kernel, it is worth
> > keeping the the definition of the TR ARP type to avoid breaking
> > userspace programs that use this file.
> 
> Thanks Stephen,  I was trying to force errors in kernel builds by
> doing these kinds of define changes while doing my delete tests.
> 
> But I was not doing userspace builds, however....
> 
> Looking back at the changes I've made, the only thing similar that
> I can see is the ipx.h changes:
> 
> diff --git a/include/linux/ipx.h b/include/linux/ipx.h
> index 3d48014..8f02439 100644
> --- a/include/linux/ipx.h
> +++ b/include/linux/ipx.h
> @@ -38,7 +38,7 @@ struct ipx_interface_definition {
>  #define IPX_FRAME_8022		2
>  #define IPX_FRAME_ETHERII	3
>  #define IPX_FRAME_8023		4
> -#define IPX_FRAME_TR_8022       5 /* obsolete */
> +/* obsolete token ring was	5 */
>  	unsigned char ipx_special;
>  #define IPX_SPECIAL_NONE	0
>  #define IPX_PRIMARY		1
> 
> Please let me/netdev know if the above also happens to trigger any
> sort of userspace fallout, and we'll fix it up ASAP.
> 
> Thanks,
> Paul.

Assume any header processed as part of 'make headers_install' is
part of kernel API and must not get broken. Therefor ipx.h
must be fixed as well. Local debug stuff should not be committed
to upstream repository!
