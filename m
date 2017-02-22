From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next RFC 1/2] flow_dissecror: Move ARP dissection
 into a separate function
Date: Wed, 22 Feb 2017 09:36:31 +0100
Message-ID: <20170222083630.GC7517@penelope.horms.nl>
References: <20170221143141.GD2694@nanopsycho.mtl.com>
 <1487687599-5464-1-git-send-email-jiri@resnulli.us>
 <20170221.133235.262226849361587925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, netdev@vger.kernel.org, tom@herbertland.com,
        eric.dumazet@gmail.com, dinan.gunawardena@netronome.com,
        mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34955 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754277AbdBVIge (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 03:36:34 -0500
Received: by mail-wm0-f48.google.com with SMTP id v186so133953217wmd.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 00:36:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170221.133235.262226849361587925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 01:32:35PM -0500, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Tue, 21 Feb 2017 15:33:18 +0100
> 
> > From: Jiri Pirko <jiri@mellanox.com>
> > 
> > Make the main flow_dissect function a bit smaller and move the ARP
> > dissection into a separate function. Along with that, do the ARP header
> > processing only in case the flow dissection user requires it.
> > 
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> 
> These two changes look fine to me, although I hope that the compiler
> doesn't decide to inline it anyways.

I think the approach taken would be a win regardless of inlining as
more logic is protected by dissector_uses_key() and thus less likely
to cause collateral damage.
