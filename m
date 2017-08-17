From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working
 with wireless drivers
Date: Wed, 16 Aug 2017 19:36:57 -0700
Message-ID: <2abaf7ec-947a-6a30-e6d3-4f75605dd50d@candelatech.com>
References: <CADps9UCgqeUh41iHxCM+CTJh=Tffn-tiSYL2Q+NBb_8EppqRMA@mail.gmail.com>
 <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net>
 <1502918561.30484.1.camel@redhat.com>
 <20170816.143116.1172751167543812070.davem@davemloft.net>
 <1502935907.30484.4.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: james-fvV4AYHggTTR7s880joybQ@public.gmane.org, futur.andy-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1502935907.30484.4.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/16/2017 07:11 PM, Dan Williams wrote:
> On Wed, 2017-08-16 at 14:31 -0700, David Miller wrote:
>> From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Date: Wed, 16 Aug 2017 16:22:41 -0500
>>
>>> My biggest suggestion is that perhaps bonding should grow
>> hysteresis
>>> for link speeds. Since WiFi can change speed every packet, you
>> probably
>>> don't want the bond characteristics changing every couple seconds
>> just
>>> in case your WiFi link is jumping around.  Ethernet won't bounce
>> around
>>> that much, so the hysteresis would have no effect there.  Or, if
>> people
>>> are concerned about response time to speed changes on ethernet
>> (where
>>> you probably do want an instant switch-over) some new flag to
>> indicate
>>> that certain devices don't have stable speeds over time.
>>
>> Or just report the average of the range the wireless link can hit,
>> and
>> be done with it.
>>
>> I think you guys are overcomplicating things.
>
> That range can be from 1 to > 800Mb/s.  No, it won't usually be all
> over that range, but it won't be uncommon to fluctuate by hundreds of
> Mb/s.  I'm not sure a simple average is really the answer here.  Even
> doing that would require new knobs to ethtool, since the rate depends
> heavily on card capabilities and also what AP you're connected to *at
> that moment*.  If you roam to another AP, then the max speed can
> certainly change.
>
> You'll probably say "aim for the 75% case" or something like that,
> which is fine, but then you're depending on your 75% case to be (a)
> single AP, (b) never move (eg, only bond wifi + ethernet), (c) little
> radio interference.  I'm not sure I'd buy that.  If I've put words in
> your mouth, forgive me.

If you keep ethtool API simple and just return the last (rx-rate + tx-rate) / 2, or the rate averaged
over the last 100 frames or 10 seconds, then the caller can do longer term averaging
as it sees fit.  Probably no need for lots of averaging complexity in the kernel.

rate-ctrl for wifi basically doesn't happen until you transmit or receive a
fairly steady stream, so it will fluctuate a lot.

Thanks,
Ben

>
> Dan
>


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
