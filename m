From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: Any way to configure a vlan interface to grab ONLY untagged frames?
Date: Mon, 14 Sep 2015 14:28:33 -0400
Message-ID: <55F711D1.9050605@gmail.com>
References: <55F5A8FC.1020707@neulinger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Nathan Neulinger <nneul@neulinger.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34663 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbINS2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 14:28:35 -0400
Received: by qkfq186 with SMTP id q186so61901673qkf.1
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 11:28:34 -0700 (PDT)
In-Reply-To: <55F5A8FC.1020707@neulinger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2015 12:49 PM, Nathan Neulinger wrote:
> It seems like running 'vconfig add IFACE 0' and using IFACE.0 would do this, but it
> doesn't actually seem to work that way.
> 
> If I capture on IFACE directly, I'd expect to get all traffic, including the tagged frames
> (with the tag intact). Looking to be able to bridge/capture/etc. and specifically only
> receive the untagged frames that haven't already been pulled out into a vlan specific
> interface.
> 
> Is there any way to accomplish this without using ebtables or other similar hacks?

If you are dealing with a hw interface, any interface that supports vlan
filtering will by default receive only untagged frames.  Only when you put
into promiscuous mode, will you receive all frames.

With bridge, you could configure your vlans adjacent to you bridge:

   vlan0...N   bridge
     |          |
     +-- eth0 --+

This way, configured vlan traffic will go to vlan devices, while all other
traffic will got bridge.  You can even limit this "all other traffic"
further, by turning on vlan filtering on the bridge which will allow
you to run eth0 in non-promiscuous mode thus enforcing HW vlan filters.

-vlad

> 
> -- Nathan
> 
> ------------------------------------------------------------
> Nathan Neulinger                       nneul@neulinger.org
> Neulinger Consulting                   (573) 612-1412
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
