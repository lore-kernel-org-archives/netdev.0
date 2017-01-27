From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a dummy network device for
 napi.
Date: Fri, 27 Jan 2017 07:25:54 -0800
Message-ID: <1485530754.6360.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485501572-20908-1-git-send-email-steffen.klassert@secunet.com>
         <1485501572-20908-3-git-send-email-steffen.klassert@secunet.com>
         <1485528398.6360.39.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170127.095349.597744818419458840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com, ilant@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36795 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932233AbdA0P0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:26:24 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so18753866pfo.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 07:25:56 -0800 (PST)
In-Reply-To: <20170127.095349.597744818419458840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-27 at 09:53 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 27 Jan 2017 06:46:38 -0800
> 
> > On Fri, 2017-01-27 at 08:19 +0100, Steffen Klassert wrote:
> >> This patch adds a dummy network device so that we can
> >> use gro_cells for IPsec GRO. With this, we handle IPsec
> >> GRO with no impact on the generic networking code.
> >> 
> >> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> >> ---
> >>  net/xfrm/xfrm_input.c | 12 +++++++++++-
> >>  1 file changed, 11 insertions(+), 1 deletion(-)
> > 
> > That is nice ;)
> 
> I like it too.
> 

If XFRM makes use of gro_cells, it is time to move it in net/core,
instead of inlining it.

I can submit this trivial patch, of course.

> I suspect we can do something similar for USB networking drivers.

With some changes then, because gro_cells is per cpu at the moment,
probably overkill for one USB networking driver.
