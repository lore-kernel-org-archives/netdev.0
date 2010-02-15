From: jamal <hadi@cyberus.ca>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark
 infrastructure
Date: Mon, 15 Feb 2010 13:59:15 -0500
Message-ID: <1266260355.6776.241.camel@bigi>
References: <xfrm-mark-net-next>
	 <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
	 <4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	 <4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
	 <4B7982AB.5060409@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f200.google.com ([209.85.210.200]:62059 "EHLO
	mail-yx0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab0BOS7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 13:59:17 -0500
Received: by yxe38 with SMTP id 38so3585623yxe.4
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 10:59:16 -0800 (PST)
In-Reply-To: <4B7982AB.5060409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-15 at 18:21 +0100, Patrick McHardy wrote:

> The xfrm route lookup doesn't use the packet mark.

I see.
Is there a historical reason why it hasnt been used this way?
Reminds me of the reverse path patch i sent a while back that
caused havoc.. (mark wasnt being used in the reverse path either)

> A couple of years ago I used this in a multipath setup, which
> was using CONNMARK to persistently bind connections (tunnels
> in this case) to a route after the first selection.

Sounds like a reasonable feature to me.

> The problem with backwards compatibility is that people using
> marks for multipath routing are most likely not expecting the
> mark to suddenly take effect for IPsec tunnel routing.

The main reason it works ok for ipsec/policy-routing is because
user space essentially pins down the kernel path. Could you
not solve it via some user space daemon? First packet/event
to user space, download policies and wait until it expires or
route/tunnel goes down to react..

One of the problems maybe the semantics of what a general purpose
tag like mark being left to either the programmer (as in connmark)
or the admin (tc) - so building a general purpose daemon would have
to enforce some semantic to work ok.

cheers,
jamal

