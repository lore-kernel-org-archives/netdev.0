From: David Martin <david.martin.mailbox@googlemail.com>
Subject: Influencing triggering of xfrm acquire messages?
Date: Thu, 11 Aug 2011 16:21:07 +0200
Message-ID: <CAGsyNe2oAkT+idnC-fuOoULTdEubbL8CabLesacjp=2tPiWVmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36021 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab1HKOVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 10:21:09 -0400
Received: by wwf5 with SMTP id 5so2097076wwf.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 07:21:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I have got a question regarding the triggering of xfrm acquire messages.

The setup is the following:
I'm using HIPL (https://launchpad.net/hipl) which implements the
Host Identity Protocol (HIP) and provides a control channel for the mutual peer
authentication and the generation of keying material. In the end of the initial
handshake, HIPL sets up the Linux Kernel IPsec implementation for the protection
of payload data.
The initial exchange is triggered by the following policy for outgoing traffic.
Note that 2001:10::/28 is the prefix for HIP addresses.

> martin@pisa1:~$ sudo ip xfrm policy
> src 2001:10::/28 dst 2001:10::/28
>    dir out priority 0
>    tmpl src :: dst ::
>        proto 0 reqid 0 mode transport

Anything matching the policy (eg. a ping matching the address prefix) triggers
an acquire message, so far so good. Everytime an acquire is triggered the kernel
sets up a SA looking like this:

> martin@pisa1:~$ sudo ip xfrm state
> src 2001:1a:a148:104c:92bb:671e:8100:9354 dst 2001:1c:5000:45b6:2d33:2c10:2726:a043
>   proto 0 reqid 0 mode transport
>   replay-window 0
>   sel src 2001:1a:a148:104c:92bb:671e:8100:9354/128 dst 2001:1c:5000:45b6:2d33:2c10:2726:a043/128 proto udp sport 49024 dport 1025

As long as it exists no additional acquire will be triggered which is a problem,
for example when shortly after an exchange the daemon is restarted and needs to
start another exchange with the same peer host.

Is this state supposed to be set up? Is it supposed to be removed automatically
once we set up our own SA? Is there a way to remove it manually to
trigger another acquire? Any input is welcome, thanks a lot in advance.

Greetings, David
