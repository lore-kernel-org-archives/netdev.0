From: John Stultz <john.stultz@linaro.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Thu, 10 Aug 2017 11:12:11 -0700
Message-ID: <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com> <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37116 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753146AbdHJSMN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 14:12:13 -0400
Received: by mail-wm0-f54.google.com with SMTP id i66so29296933wmg.0
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 11:12:12 -0700 (PDT)
In-Reply-To: <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 10:41 PM, Wei Wang <weiwan@google.com> wrote:
> Hi John,
>
> Is it possible to try the attached patch?

Thanks so much for the quick turn around!

So I dropped all the reverts you suggested, and applied this one
against 4.13-rc4, but I'm still seeing the problematic behavior.

> I am not sure if it actually fixes the issue. But I think it is worth a try.
> Also, could you get me all the ipv6 routes when you plug in the usb
> using "ip -6 route show"? (If you have multiple routing tables
> configured, could you dump them all?)

# ip -6 route show
2601:1c2:1002:83f0::/64 dev eth0  proto kernel  metric 256  expires
345599sec pref medium
fe80::/64 dev eth0  proto kernel  metric 256  pref medium
default via fe80::200:caff:fe11:2233 dev eth0  proto ra  metric 1024
expires 1799sec hoplimit 64 pref medium


After unplugging the device (and getting the unregister_netdevice errors):
# ip -6 route show
#


thanks
-john
