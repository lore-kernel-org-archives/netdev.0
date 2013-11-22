From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] Workaround for Suspend/Resume issue of AX88772B under ChromeOS
Date: Thu, 21 Nov 2013 18:42:22 -0800
Message-ID: <CAGVrzcY14kHeDkSYDz6Pcjr1-s-EcFnqS37DQKcXkPwBm0_EHA@mail.gmail.com>
References: <1384913496-26261-1-git-send-email-freddy@asix.com.tw>
 <20131120.004026.2013972041095203460.davem@davemloft.net> <CANEJEGtBmvFNcFzOW9ZnOFd=ZMnz82ajcN52YqW3+n0+=rhxBA@mail.gmail.com>
 <20131120.135413.920731121262719289.davem@davemloft.net> <CANEJEGtXOjxj+85QVfWFGH6WuxxCz6uAfEuUo7bv9YEwh_8OAw@mail.gmail.com>
 <CANEJEGu_2YdVOjcnzh30RPMiP0KC5bL6JasxMS_+1xV9poxgQw@mail.gmail.com>
 <CAGVrzcase25NosVHA74OLnviJj7nU_2Rxki_hvi8bOwznDuWGg@mail.gmail.com> <CANEJEGuo4rbz4hP=RfN8A+4ozjuJ7oZmtLcmkjbkxrGZrpRr5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	davemloft <davemloft@davemloft.net>,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>,
	Allan Chou <allan@asix.com.tw>,
	Daniel_ASIX <daniel@asix.com.tw>
To: Grant Grundler <grundler@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGuo4rbz4hP=RfN8A+4ozjuJ7oZmtLcmkjbkxrGZrpRr5A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/11/21 Grant Grundler <grundler@google.com>:
> On Thu, Nov 21, 2013 at 5:58 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> ...
>>> Freddy sent me a patch that saves/restores MII_ADVERTISE and MII_BMCR
>>> registers. Testing that now and he'll post if that all works out.
>
> Bad News: Freddy's patch didn't work and needs to be rework it.
>
>> That should be enough to ensure the PHY is put back into a consistent
>> state. So long as you are suspending/resuming from a configuration
>> where autoneg was enabled, I would not expect anything bad to happen.
>
> Well, I think davem NACK'd that approach (the original patch in this
> thread did that).
>
>> If the link was forced, that is a different story.
>>
>> One way to make sure this work properly without driver-specific code
>> is to include that functionality into the PHY library. As far as I can
>> see it the asix drivers do not use it but implement the old-style
>> mii_bus interface so that would be a first step.
>
> AFAICT, many USBNET drivers support mii_bus interface. Can you point
> at a good example of a USBNET driver that is supporting PHY lib?

drivers/net/usb/ax88172a.c implements the PHY library calls.

>
> I also didn't see anything in usbnet_resume() code path that calls
> into a phy lib. So it seems that some infrastructure still needs to
> happen if that's considered a feasible.

There are still some pending patches to make sure that suspend/resume
are properly being taken care of when issuing phy_stop/phy_start, but
once that is done, you would not have to call anything in
usbnet_resume(), the driver's ndo_open() callback would call
phy_start() which would resume the PHY into the state it was before
suspending.
-- 
Florian
