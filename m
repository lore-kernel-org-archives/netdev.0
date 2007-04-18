From: Erik Hovland <erik@hovland.org>
Subject: Re: [PATCH] Make dev_kfree_skb_any check if the skb is valid
Date: Wed, 18 Apr 2007 16:18:15 -0700
Message-ID: <20070418231808.GF13146@hovland.org>
References: <20070418223339.GE13146@hovland.org> <20070418.154416.131918019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:46167 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992956AbXDRXSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 19:18:24 -0400
Received: from dsl092-045-201.lax1.dsl.speakeasy.net (HELO speakeasy.net) ([66.92.45.201])
          (envelope-sender <erik@hovland.org>)
          by mail8.sea5.speakeasy.net (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 18 Apr 2007 23:18:22 -0000
Content-Disposition: inline
In-Reply-To: <20070418.154416.131918019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2007 at 03:44:16PM -0700, David Miller wrote:
> From: Erik Hovland <erik@hovland.org>
> Date: Wed, 18 Apr 2007 15:33:44 -0700
> 
> > If dev_kfree_skb_any is called and it then calls dev_kfree_skb_irq.
> > That call will dereference the skb. If the skb is invalid, down the
> > drain we go.
> > 
> > This one-liner checks to see if the skb is valid as part of the
> > determination of whether to call dev_kfree_skb_irq.
> > 
> > Signed-off-by: Erik Hovland <erik@hovland.org>
> 
> This should never be invoked with a NULL skb argument.
>
> Who is doing that?

Heh, the reason I came up with this patch is that the code in
drivers/usb/gadget/ether.c at about line 1653 will attempt to allocate
an skb. If it fails then it uses a goto to jump to line 1672 where it
will call dev_kfree_skb_any (skb) on a potentially null skb. I put a
validity check there and sent it off to the USB gadget maintainer. He
asked me to instead make the dev_kfree_skb_any call more robust and see
how that went over on the netdev list. Like a lead balloon?

E

-- 
Erik Hovland
mail: erik@hovland.org
web: http://hovland.org/
PGP/GPG public key available on request

