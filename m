From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: update ubuf_info initialization
 to anonymous union
Date: Mon, 28 Aug 2017 15:17:52 -0700 (PDT)
Message-ID: <20170828.151752.246788024466105849.davem@davemloft.net>
References: <20170825171043.84011-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
        paul.durrant@citrix.com, kbuild-all@01.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751215AbdH1WRx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:17:53 -0400
In-Reply-To: <20170825171043.84011-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 25 Aug 2017 13:10:43 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> The xen driver initializes struct ubuf_info fields using designated
> initializers. I recently moved these fields inside a nested anonymous
> struct inside an anonymous union. I had missed this use case.
> 
> This breaks compilation of xen-netback with older compilers.
> From kbuild bot with gcc-4.4.7:
> 
>    drivers/net//xen-netback/interface.c: In function
>    'xenvif_init_queue':
>    >> drivers/net//xen-netback/interface.c:554: error: unknown field 'ctx' specified in initializer
>    >> drivers/net//xen-netback/interface.c:554: warning: missing braces around initializer
>       drivers/net//xen-netback/interface.c:554: warning: (near initialization for '(anonymous).<anonymous>')
>    >> drivers/net//xen-netback/interface.c:554: warning: initialization makes integer from pointer without a cast
>    >> drivers/net//xen-netback/interface.c:555: error: unknown field 'desc' specified in initializer
> 
> Add double braces around the designated initializers to match their
> nested position in the struct. After this, compilation succeeds again.
> 
> Fixes: 4ab6c99d99bb ("sock: MSG_ZEROCOPY notification coalescing")
> Reported-by: kbuild bot <lpk@intel.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

APplied.
