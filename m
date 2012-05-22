From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Tue, 22 May 2012 19:24:57 +0200
Message-ID: <1337707497.3361.233.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	 <88c43001441945e1431609db252b69e7@visp.net.lb>
	 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
	 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	 <4775d023592b876909aceb152f94aa01@visp.net.lb>
	 <1337540825.3361.0.camel@edumazet-glaptop>
	 <ef780bd0e0b9b9e60e37fa74101f0f66@visp.net.lb>
	 <1337572583.3361.8.camel@edumazet-glaptop>
	 <6d7500e1c3b4b191c0b5a11003b161d6@visp.net.lb>
	 <1337589005.3361.19.camel@edumazet-glaptop>
	 <1337589620.3361.23.camel@edumazet-glaptop>
	 <eb8cdd693530010d6736baede0cfebd8@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44853 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979Ab2EVRZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 13:25:01 -0400
Received: by eeit10 with SMTP id t10so1795744eei.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 10:25:00 -0700 (PDT)
In-Reply-To: <eb8cdd693530010d6736baede0cfebd8@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 20:11 +0300, Denys Fedoryshchenko wrote:

> By the way, if BQL limit is going lower than MTU, is it considered as a 
> bug?
> If yes, i can try to upload 3.4 to some servers and add condition to 
> WARN_ON if limit < 1500.

There is no problem with BQL limit going lower than the max packet size.

(With TSO it can be 64K)

Remember BQL allows one packet to be sent to device, regardless of its
size.

Next packet might be blocked/stay in Qdisc

If your workload is mostly idle, but sending bursts of 3 packets, then
only one is immediately sent.

Next packets shall wait the TX completion of first packet.
