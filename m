From: John Stultz <john.stultz@linaro.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Wed, 9 Aug 2017 16:44:26 -0700
Message-ID: <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com> <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        Wei Wang <weiwan@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 4:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> (Cc'ing Wei whose commit was blamed)
>
> On Mon, Aug 7, 2017 at 2:15 PM, John Stultz <john.stultz@linaro.org> wrote:
>> On Mon, Aug 7, 2017 at 2:05 PM, John Stultz <john.stultz@linaro.org> wrote:
>>> So, with recent testing with my HiKey board, I've been noticing some
>>> quirky behavior with my USB eth adapter.
>>>
>>> Basically, pluging the usb eth adapter in and then removing it, when
>>> plugging it back in I often find that its not detected, and the system
>>> slowly spits out the following message over and over:
>>>   unregister_netdevice: waiting for eth0 to become free. Usage count = 1
>>
>> The other bit is that after this starts printing, the board will no
>> longer reboot (it hangs continuing to occasionally print the above
>> message), and I have to manually reset the device.
>>
>
> So this warning is not temporarily shown but lasts until a reboot,
> right? If so it is a dst refcnt leak.

Correct, once I get into the state it lasts until a reboot.

> How reproducible is it for you? From my reading, it seems always
> reproduced when you unplug and plug your usb eth interface?
> Is there anything else involved? For example, network namespace.

So with 4.13-rc3/4 I seem to trigger it easily, often with the first
unplug of the USB eth adapter.

But as I get back closer to 4.12, it seemingly becomes harder to
trigger, but sometimes still happens.

So far, I've not been able to trigger it with 4.12.

I don't think network namespaces are involved?  Though its out of my
area, so AOSP may be using them these days.  Is there a simple way to
check?

I'll also do another bisection to see if the bad point moves back any further.

thanks
-john
