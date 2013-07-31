From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH v3 1/3] net/usb/r815x: replace USB buffer from stack to DMA-able
Date: Wed, 31 Jul 2013 18:29:47 +0800
Message-ID: <CACVXFVNH=71cEncYfJRAf61j-WJWmoZrs+PdsC1XtWybu8v-Gw@mail.gmail.com>
References: <20130730140059.GE27962@kroah.com>
	<20130730.113329.1450325193505423812.davem@davemloft.net>
	<1375209677.2075.129.camel@joe-AO722>
	<20130730.114900.5636932806999400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: joe@perches.com, gregkh@linuxfoundation.org, hayeswang@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730.114900.5636932806999400.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 31, 2013 at 2:49 AM, David Miller <davem@davemloft.net> wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 30 Jul 2013 11:41:17 -0700
>
>> On Tue, 2013-07-30 at 11:33 -0700, David Miller wrote:
>>> From: Greg KH <gregkh@linuxfoundation.org>
>>> Date: Tue, 30 Jul 2013 07:00:59 -0700
>>>
>>> > This call is so slow, you can afford to make a call to kmalloc for the
>>> > data, as it sure just did for other structures it needed :)
>>>
>>> I told him to implement things this way, to avoid calling kmalloc every
>>> single register access.
>>>
>>> Using kmalloc all the time makes the access fragile, since a badly timed
>>> call during high memory pressure can fail.
>>>
>>> I'd rather the potential failure happen at one time, probe time.
>>>
>>> In any event, Ming Lei has suggested using usbnet_{read,write}_cmd()
>>> instead, which sounds like a good solution to this problem.
>>
>> Those do per-call allocs too.
>
> Sigh...  Ok I won't fight this any longer then :-)

It might not be a big deal because most of these commands are sent
during probe()/ethtool/... context, and not in tx/rx path.

Another choice is to reserve a big enough buffer during probe()
for read/write command, but one mutex is needed too for avoiding
concurrent calling.

Anyway, please call the command API to do such thing, so that we
can improve it easily in future.

Thanks,
-- 
Ming Lei
