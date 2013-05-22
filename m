From: David Hauweele <david@hauweele.net>
Subject: Re: [PATCH beta 1] 0/3] Fix race conditions in mrf24j40 interrupts
Date: Wed, 22 May 2013 22:32:15 +0200
Message-ID: <CAO+c-UV1bZZEE=9=7VVn3f1eLWzCpYCK9eZnnvzNwcPOKKtKLA@mail.gmail.com>
References: <CAO+c-UVJQJbmmmCS4hxAEYHKa8gEU1Bs=y+Rv_A75UHeBZxc+w@mail.gmail.com>
	<1369188080-8904-1-git-send-email-alan@signal11.us>
	<519C278F.5030809@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519C278F.5030809@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I cannot use level-triggered interrupts with GPIO on the RPi, so I
cannot test this specific patch.
However I agree with the idea of level-triggered interrupts, that
would fix all major problems related to missed interrupts.

Beside this I'm running a ping -f since more than two hours now and it
seems to work well.

David

2013/5/22 Alan Ott <alan@signal11.us>:
> On 05/21/2013 10:01 PM, Alan Ott wrote:
>> David Hauweele noticed that the mrf24j40 would hang arbitrarily after some
>> period of heavy traffic.  Two race conditions were discovered, and the
>> driver was changed to use threaded interrupts, since the enable/disable of
>> interrupts in the driver has recently been a lighning rod whenever issues
>> arise related to interrupts (costing engineering time), and since threaded
>> interrupts are the right way to do it.
>>
>> Alan Ott (3):
>>   mrf24j40: Move INIT_COMPLETION() to before packet transmission
>>   mrf24j40: Use threaded IRQ handler
>>   mrf24j40: Use level-triggered interrupts
>>
>>  drivers/net/ieee802154/mrf24j40.c | 31 +++++++++----------------------
>>  1 file changed, 9 insertions(+), 22 deletions(-)
>
> I forgot to add, I ran ping -f both ways all afternoon (6.5 hours), and
> it seems solid.
>
