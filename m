From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 16:42:52 -0500
Message-ID: <1266442972.17794.51.camel@bigi>
References: <20100217191718.GA5256@x200>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f178.google.com ([209.85.221.178]:56050 "EHLO
	mail-qy0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757320Ab0BQVmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:42:55 -0500
Received: by qyk8 with SMTP id 8so2300722qyk.24
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 13:42:54 -0800 (PST)
In-Reply-To: <20100217191718.GA5256@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 21:17 +0200, Alexey Dobriyan wrote:
> commit 19f4c7133fc1b94001b997c4843d0a9192ee63e5
> xfrm: Flushing empty SAD generates false events
> 
> commit 0dca3a843632c2fbb6e358734fb08fc23e800f50
> xfrm: Flushing empty SPD generates false events
> 
> setkey now takes several seconds to run this simple script
> and it spits "recv: Resource temporarily unavailable" messages.

I will try to reproduce it in about an hour. Do you have
anything like selinux being used etc?
 
BTW, the script seems a little strange because i think 
the template wont match between the SA/SP.. (doesnt
matter if you are testing insertion/flushing)

Does the following look reasonable for testing?
----
#!/usr/sbin/setkey -f
flush;
spdflush;

add 192.168.1.2 192.168.1.3 ipcomp 44 -m tunnel -C deflate;
add 192.168.1.3 192.168.1.2 ipcomp 45 -m tunnel -C deflate;

spdadd 10.0.1.2 10.1.2.3 any -P in ipsec
        ipcomp/tunnel/192.168.1.2-192.168.1.3/use;
spdadd 10.1.2.3 10.0.1.2 any -P out ipsec
        ipcomp/tunnel/192.168.1.3-192.168.1.2/use;
-----

cheers,
jamal

