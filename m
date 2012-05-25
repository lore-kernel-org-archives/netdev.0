From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Fri, 25 May 2012 19:18:15 +0200
Message-ID: <1337966295.3347.57.camel@edumazet-glaptop>
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
	 <1337707497.3361.233.camel@edumazet-glaptop>
	 <CA+mtBx-gOcfOE91LnUpdq4PqM5KQusTn5WKcq0t2xvU7XM80Pg@mail.gmail.com>
	 <1337926938.7753.8.camel@edumazet-glaptop>
	 <CA+mtBx8fpS_w7X2iq+tOEFuFhhgJ-4V_1ubBsd8-MvvmCef45w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62204 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756553Ab2EYRST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 13:18:19 -0400
Received: by eaak11 with SMTP id k11so302946eaa.19
        for <netdev@vger.kernel.org>; Fri, 25 May 2012 10:18:18 -0700 (PDT)
In-Reply-To: <CA+mtBx8fpS_w7X2iq+tOEFuFhhgJ-4V_1ubBsd8-MvvmCef45w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-25 at 09:59 -0700, Tom Herbert wrote:
> > TX completion has no budget, I am not sure what you mean.
> >
> Right, it's the budget on RX that can be a factor.  TX completion is
> done from the NAPI poll routine, so if RX does not complete the NAPI
> is rescheduled and TX completion is done again for the same HW
> interrupt.
> 
> We need to remove the constraint that netdev_completed can only be
> called once per interrupt...

Not clear where is this constraint in the code.

Under heavy load, we can be in a loop situation, one cpu serving NAPI
for a bunch of devices (no more hardware interrupts are delivered since
we dont re-enable them at all)
