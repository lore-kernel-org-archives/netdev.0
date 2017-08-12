From: John Stultz <john.stultz@linaro.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Fri, 11 Aug 2017 17:31:44 -0700
Message-ID: <CALAqxLV-e=Uz_zG6VYcKSTG0+qJdpPOv0_vagnGx4bABgzO4tg@mail.gmail.com>
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
 <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w@mail.gmail.com> <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Martin KaFai Lau <kafai@fb.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: Wei Wang <weiwan@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2017 at 5:10 PM, Wei Wang <weiwan@google.com> wrote:
>> If after Cong's fix, the issue still happens, could you help try the
>> patch attached and collect all logs when you try the reproduce the
>> issue? It would be great to have logs for both success case and the
>> failure case.
>>
>> Thanks so much for your help.
>>
>
> I think we have a potential fix for this issue.
> Martin and I found that when addrconf_dst_alloc() creates a rt6, it is
> possible that rt6->dst.dev points to loopback device while
> rt6->rt6i_idev->dev points to a real device.
> When the real device goes down, the current fib6 clean up code only
> checks for rt6->dst.dev and assumes rt6->rt6i_idev->dev is the same.
> That leaves unreleased refcnt on the real device if rt6->dst.dev
> points to loopback dev.
>
> The attached potential fix is tested by Martin and made sure it fixes his issue.
>
> John,
> It will be great if you can also give it a try and see if it fixes the
> issue on your side before I submit an official patch.

So yes, sorry I haven't been able to get back quicker on the other
patches sent, was mucking about in other work.

So yea, this patch  (potential fix for unregister_netdevice()) seems
to avoid the issue.

I'm going to do some further testing, but its looking good so far.

Do you still want feedback on the previous changes?

thanks
-john
