From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Mon, 24 Aug 2015 21:12:26 +0300
Message-ID: <55DB5E8A.9040108@rosalab.ru>
References: <55D436D5.6010105@rosalab.ru> <87k2sreefu.fsf@nemi.mork.no>
 <55D46F85.50608@rosalab.ru>
 <20150824.104328.554582952440857559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, oneukum@suse.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150824.104328.554582952440857559.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

24.08.2015 20:43, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
> Date: Wed, 19 Aug 2015 14:59:01 +0300
>
>> So the following might be possible, although unlikely:
>>
>> CPU0             CPU1
>>                   clear_bit: read dev->flags
>>                   clear_bit: clear EVENT_RX_KILL in the read value
>>
>> dev->flags=3D0;
>>
>>                   clear_bit: write updated dev->flags
>>
>> As a result, dev->flags may become non-zero again.
>
> Is this really possible?

On x86, it is not possible, so this is not a problem. Perhaps, for ARM=20
too. As for the other architectures supported by the kernel - not sure,=
=20
no common guarantees, it seems. Anyway, this is not a critical issue, I=
=20
agree.

OK, let us leave things as they are for this one and fix the rest.

>
> Stores really are "atomic" in the sense that the do their update
> in one indivisible operation.
>
> Atomic operations like clear_bit also will behave that way.
>
> If a clear_bit is in progress, the "dev->flags=3D0" store will not be
> able to grab the cache line exclusively until the clear_bit is done.
>
> So I think the above sequent of events is completely impossible.  Onc=
e
> a clear_bit starts, a write by another foreign agent on the bus is
> absolutely impossible to legally occur until the clear_bit completes.
>
> I think this is a non-issue.
>

Regards,
Eugene
