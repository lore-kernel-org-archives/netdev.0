From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 3/9] gue: Changes to ip_tunnel to support Generic
 UDP Encapsulation
Date: Sun, 20 Jul 2014 20:31:18 -0700
Message-ID: <CA+mtBx9+i35xJjDmupJY7UA5quW=Cfmq2aQ6r3j7iJ0M8WmtHg@mail.gmail.com>
References: <alpine.DEB.2.02.1407162055520.29792@tomh.mtv.corp.google.com>
	<20140717.145345.1627726281054820171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:41759 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbaGUDbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 23:31:19 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so2407136igc.6
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 20:31:18 -0700 (PDT)
In-Reply-To: <20140717.145345.1627726281054820171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 2:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 16 Jul 2014 21:14:44 -0700 (PDT)
>
>> This patch changes IP tunnel to support (secondary) encapsulation,
>> Generic UDP Encapsulation. Changes include:
>>
>> 1) Adding tun_hlen as the tunnel header length, encap_hlen as the
>> encapsulation header length (GUE), and hlen becomes the grand total
>> of these.
>> 2) Added generic function to handle IOCTLs
>> 3) Added IOCTLs to setup or remove encapsulation. This includes
>> uapi to configure encapsulation on a tunnel.
>> 4) Support to perform GUE encapsulation in ip_tunnel_xmit.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> Please extend the netlink interface for creating IP tunnels rather
> than adding things to the the deprecated ioctl interface.

Changing to the IP tunnel code to use netlink instead of ioctls looks
like a pretty major undertaking. I don't recall the tunnel ioctl's
being particularly problematic and extending them for GUE wasn't
particularly difficult. I can do this migration if it's really needed,
but I'd like to know that there's a real value behind it and it's not
just an academic exercise. Also, tuntap is still using ioctls, would
we need to move that to netlink for same reasons?

Thanks,
Tom
