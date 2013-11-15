From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 1/2] net: phylib: add adjust_state callback to phy device
Date: Fri, 15 Nov 2013 08:35:00 +0100
Message-ID: <5285CEA4.70207@gmail.com>
References: <1384376870-7810-1-git-send-email-zonque@gmail.com> <20131114.163207.230147902479371528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marek.belisko@gmail.com,
	ujhelyi.m@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:63483 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab3KOHfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 02:35:05 -0500
Received: by mail-bk0-f43.google.com with SMTP id mz13so1484367bkb.16
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 23:35:03 -0800 (PST)
In-Reply-To: <20131114.163207.230147902479371528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 10:32 PM, David Miller wrote:
> From: Daniel Mack <zonque@gmail.com>
> Date: Wed, 13 Nov 2013 22:07:49 +0100
> 
>> Allow phy drivers to take action when the core does its link adjustment.
>> No change for drivers that do not implement this callback.
>>
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
> 
> So you're using this to reset the entire PHY via the reset bit in the
> BMCR register when the link goes down.
> 
> But this is going to break things.
> 
> If the phy library previously programmed a non-autonegotiated static
> link configuration into the BMCR register, your reset is going to
> undo that.
> 
> Now the configuration phylib thinks the chip has and the one it
> acutally does is out of sync.

You're right, thanks for the review. Let me just state that I'm really
unhappy about that approach as well.

However, I currently see no better way than resetting the PHY every time
the link goes down, as we have no way of telling whether the chip has
entered its locked-up state which it seemingly does arbitrarily when the
link changes. This is really not nice, but the only thing that avoided
the effect in our tests.

That means that we either have to tell the PHY core about what we did,
or manually preserve the registers contents across the reset. I'll have
another look next week. Any pointers appreciated :)


Daniel
