From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Socket owner problem?
Date: Tue, 11 Sep 2007 14:13:22 +0200
Message-ID: <20070911141322.1c62bc8b@oldman>
References: <1189496159.849702.82190@50g2000hsm.googlegroups.com>
	<8d33dcd40709110045v532e062ex7f05ac3ba9386161@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Alvin Valera" <alvinvalera@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35455 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753194AbXIKMMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 08:12:41 -0400
In-Reply-To: <8d33dcd40709110045v532e062ex7f05ac3ba9386161@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2007 15:45:29 +0800
"Alvin Valera" <alvinvalera@gmail.com> wrote:

> I am currently writing a kernel module that will apply some delay to
> incoming packets. The module is implemented using netfilter hooked
> into the NF_IP_LOCAL_IN. Once the module receives a packet of interest
> from the lower layer, it will queue the packet (in it's own queue) and
> associate a kernel timer. Once the kernel timer expires, the packet is
> then propagated up the higher layer.

Can be done already with netem and ifb already.

Netfilter is intended for only yes/no decisions, not time alteration.

> The problem happens like this:
> Once the socket is closed by the user-space application, there are
> still packets left in the module's queue. Now, the moment the kernel
> timer expires and the module propagates those packets up into the
> higher layer, the system hangs.
> 
> I've been searching for ways to determine if associated socket is
> closed. This way, if my module knows that the user-space already
> closed the socket, it will not propagate the packet up. Does anyone
> have a solution for this problem?
> 
> Thanks!

Please put networking discussions on netdev@vger.kernel.org

