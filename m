From: Tom Herbert <therbert@google.com>
Subject: Re: Receive steering and hash and cache misses
Date: Fri, 2 Apr 2010 10:59:43 -0700
Message-ID: <g2l65634d661004021059z94214a43v82409d15a0fb09b6@mail.gmail.com>
References: <20100402102650.5bdb5b52@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:34010 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab0DBR7r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 13:59:47 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o32HxjNl013579
	for <netdev@vger.kernel.org>; Fri, 2 Apr 2010 19:59:45 +0200
Received: from gyd12 (gyd12.prod.google.com [10.243.49.204])
	by wpaz1.hot.corp.google.com with ESMTP id o32Hxh3r002809
	for <netdev@vger.kernel.org>; Fri, 2 Apr 2010 10:59:44 -0700
Received: by gyd12 with SMTP id 12so1003874gyd.16
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 10:59:43 -0700 (PDT)
In-Reply-To: <20100402102650.5bdb5b52@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 2, 2010 at 10:26 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>
> Although Receive Packet Steering can use a hardware generated receive=
 hash
> the device driver still causes an unnecessary cache miss on the inter=
rupt
> processing CPU. =A0The current Ethernet network device driver receive=
 processing
> has the device driver calling eth_type_trans() which causes a the
> interrupt CPU to read the received frame header.
>

It should be possible to deduce the values set by eth_type_trans from
the RX descriptor along with the RX hash.  I'll post the patch getting
rxhash from bnx2x which does this.

> Is there some way the hardware receive hash value could be used to
> steer to the receive CPU, then have the receive CPU find the Ethernet
> type field (eth_type_trans)?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
