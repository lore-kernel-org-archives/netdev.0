From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Why not refresh ipv6 local link address of a bridge when a new
 interface added to the bridge?
Date: Mon, 26 Sep 2011 08:51:17 -0700
Message-ID: <20110926085117.1a749151@nehalam.linuxnetplumber.net>
References: <CA+UXGK1Ej4DeS5-=FO0ejMCGjWfptxxxRibhMi2-duE9Cx2D_g@mail.gmail.com>
	<CA+UXGK1XAgCxYUoOAP6yQSGhzDB-3p3oDqOoOc_e=rTT3DPx7Q@mail.gmail.com>
	<CA+UXGK3yQzUuZwHWooxd91G77ACvYzwTQUOoDdVc-=CCEv4POQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Xiong <bottomofstack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40674 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab1IZPv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 11:51:27 -0400
In-Reply-To: <CA+UXGK3yQzUuZwHWooxd91G77ACvYzwTQUOoDdVc-=CCEv4POQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2011 10:39:31 +0800
Eric Xiong <bottomofstack@gmail.com> wrote:

> Hi all:
> Sorry for disturb! when adding a interface to bridge, maybe the bridge
> mac address will be changed. the bridge code don't invoke
> call_netdevice_notifiers to notify ipv6 code to refresh local link
> address. I don't know why. Thanks for your help!
> 
> BRs.

This change went in for v3.1


    Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.
    
    This ensures the neighbor entries associated with the bridge
    dev are flushed, also invalidating the associated cached L2 headers.
    
    This means we br_add_if/br_del_if ports to implement hand-over and
    not wind up with bridge packets going out with stale MAC.
    
    This means we can also change MAC of port device and also not wind
    up with bridge packets going out with stale MAC.
    
    This builds on Stephen Hemminger's patch, also handling the br_del_if
    case and the port MAC change case.
    
    Cc: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Andrei Warkentin <andreiw@motorola.com>
    Acked-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
