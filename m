From: Sergio Luis <eeeesti@gmail.com>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Tue, 14 Jul 2009 14:17:21 -0300
Message-ID: <ce0170d90907141017h732c2cd7ja5990303093b6edd@mail.gmail.com>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
	 <20090404.170539.148727646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: amluto@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755840AbZGNRRZ@vger.kernel.org>
In-Reply-To: <20090404.170539.148727646.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

On Sat, Apr 4, 2009 at 9:05 PM, David Miller<davem@davemloft.net> wrote:
> From: Andrew Lutomirski <amluto@gmail.com>
> Date: Wed, 1 Apr 2009 11:40:06 -0400
>
>> When a network driver registers a new interface, linkwatch will not notice,
>> and hence not set the rfc2863 operstate, until netif_carrier_on gets called.
>> If the new interface has no carrier when it is connected, then a status of
>> "unknown" is reported to userspace, which confuses various tools
>> (NetworkManager, for example).
>>
>> This fires a linkwatch event for all new interfaces, so that operstate
>> gets set reasonably quickly.
>>
>> Signed-off-by: Andrew Lutomirski <amluto@gmail.com>
>
> The default assumed state for a freshly registered network
> device is that the link is up.
>
> If that disagrees from reality, the driver should make the
> appropriate netif_carrier_off() call.
>
> I'm sure you'll find that the e1000 driver is not doing this
> and that is what causes the bug you are seeing.
> --

is this patch incorrect, though? with the linkwatch_fire_event() call,
the rfc2863 operstate will be set for everyone at device register
time.
in here I am having the interface operstate as 'unknown', but I do
ifconfig down and up or unplug/plug the cable again it will finally
set the correct rfc2863 operstate.

or should this be fixed on a per-driver basis, like it apparently was
in this case, for his e1000? (drivers/net/skge.c in here).

thanks,
sergio
