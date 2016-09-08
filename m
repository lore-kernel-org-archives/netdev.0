From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Thu, 8 Sep 2016 08:39:20 -0700
Message-ID: <20160908083920.0d421951@xeon-e3>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36492 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030231AbcIHPjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 11:39:10 -0400
Received: by mail-pf0-f181.google.com with SMTP id 128so19290718pfb.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 08:39:10 -0700 (PDT)
In-Reply-To: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Sep 2016 15:06:16 +0200
"D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name> wrote:

> Hello,
> 
> I'd like to start a discussion if it makes sense to add an optional feature
> 
> to the bridge MAC address learning code to generate kernel uevents for
> 
> every learned (added) and removed MAC address.
> 
> The (my) rationale behind this is, that I work with multiport SRIOV and 
> MRIOV
> 
> network cards that cannot put each and every virtual port into promiscuous
> 
> mode, but they have the capability to register a large number of MAC 
> addresses
> 
> to each interface.
> 
> These systems are host to a large number of kvm guests, that require 
> network access.
> 
> To get around the problem I added two uevents to linuxbridge that would 
> announce every
> 
> learned address to udev, and udev would register or remove  the MAC 
> address to the
> 
> uplink device of the bridge.
> 
> The script may also add the required addresses for multicast and IPv6 if 
> required.
> 
> The need for promiscuous mode on the card was gone. All I needed to do 
> was to attach
> 
> the guests through a linuxbridge instead of directly to the card.
> 
> 
> I may be missing something here - I'm pretty sure there I am, but is 
> there any conceptual
> 
> reason why this should not be done this way ?
> 
> 
> I'm porting my patch (for 3.10.0) to head, and will make it available, I 
> just want some
> 
> valuable feedback as early as possible.
> 
> 
> Thanks, D.Herrendoerfer

This should be possible by listening for netlink events.
No need for udev interaction.
