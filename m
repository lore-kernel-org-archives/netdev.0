From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Tue, 4 Oct 2011 15:11:01 -0400
Message-ID: <20111004191101.GA17483@synalogic.ca>
References: <20111004041444.793960297@vyatta.com>
 <20111004041509.292932641@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42727 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820Ab1JDTLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 15:11:07 -0400
Received: by vcbfk10 with SMTP id fk10so685076vcb.19
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2011 12:11:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20111004041509.292932641@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-10-03 21:14, Stephen Hemminger wrote:
> This is based on an earlier patch by Nick Carter with comments
> by David Lamparter but with some refinements. Thanks for their patience
> this is a confusing area with overlap of standards, user requirements,
> and compatibility with earlier releases.
> 
> It adds a new sysfs attribute 
>    /sys/class/net/brX/bridge/group_fwd_mask
> that controls forwarding of frames with address of: 01-80-C2-00-00-0X
> The default setting has no forwarding to retain compatibility.
> 
> One change from earlier releases is that forwarding of group
> addresses is not dependent on STP being enabled or disabled. This
> choice was made based on interpretation of tie 802.1 standards.
> I expect complaints will arise because of this, but better to follow
> the standard than continue acting incorrectly by default.
> 
> The filtering mask is writeable, but only values that don't forward
> known control frames are allowed. It intentionally blocks attempts
> to filter control protocols. For example: writing a 8 allows
> forwarding 802.1X PAE addresses which is the most common request.
> 

Indeed, I have tested this patch with kvm + tap + bridge to
authenticate/authorize a virtual machine connected to a 802.1X enabled
switch. It works swell.

Tested-by: Benjamin Poirier <benjamin.poirier@gmail.com>
