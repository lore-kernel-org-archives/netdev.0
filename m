From: Wei Wang <weiwan@google.com>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Fri, 11 Aug 2017 17:25:58 -0700
Message-ID: <CAEA6p_CxiwXzQHgLA_Oma0pfayYReGc5QmJkV=Td9M1Kdqwbzg@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
 <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
 <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
 <CAM_iQpWMWg5ytDq2Y9p9uet1zowGuCX+eksyiyxu9vQ18WoPxQ@mail.gmail.com>
 <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w@mail.gmail.com>
 <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com> <a2a0f380-3e49-8772-dde9-bcebd94cd7fd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Martin KaFai Lau <kafai@fb.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:36751 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHLA0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 20:26:00 -0400
Received: by mail-ua0-f169.google.com with SMTP id k43so20882356uaf.3
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 17:26:00 -0700 (PDT)
In-Reply-To: <a2a0f380-3e49-8772-dde9-bcebd94cd7fd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 5:19 PM, David Ahern <dsahern@gmail.com> wrote:
> On 8/11/17 6:10 PM, Wei Wang wrote:
>> I think we have a potential fix for this issue.
>> Martin and I found that when addrconf_dst_alloc() creates a rt6, it is
>> possible that rt6->dst.dev points to loopback device while
>> rt6->rt6i_idev->dev points to a real device.
>> When the real device goes down, the current fib6 clean up code only
>> checks for rt6->dst.dev and assumes rt6->rt6i_idev->dev is the same.
>> That leaves unreleased refcnt on the real device if rt6->dst.dev
>> points to loopback dev.
>
> Yes, host routes and anycast routes.
>
> I have a patch to fix that but it is held up on a few VRF test cases
> failing. Hopefully I can get that figured out next week. These unrelated
> routes against the loopback device have been a source of a number of
> problems (e.g. take down 'lo' and all of IPv6 networking stops for that
> namespace).

Thanks David.
By "a patch to fix that" do you mean after your patch, for every rt6,
rt6->rt6i_idev will be the same as rt6->dst.dev?
