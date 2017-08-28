From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: update ubuf_info initialization to
 anonymous union
Date: Mon, 28 Aug 2017 10:16:54 +0100
Message-ID: <20170828091654.r6o6gejzi4jcitue@citrix.com>
References: <20170825171043.84011-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
        <kbuild-all@01.org>, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:22875 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdH1J0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 05:26:32 -0400
Content-Disposition: inline
In-Reply-To: <20170825171043.84011-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 01:10:43PM -0400, Willem de Bruijn wrote:
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

Acked-by: Wei Liu <wei.liu2@citrix.com>
