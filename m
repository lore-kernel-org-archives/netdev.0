From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink - notify when the socket gets closed
Date: Sun, 07 Dec 2008 17:04:31 +0100
Message-ID: <493BF40F.6050307@trash.net>
References: <35476bd20812050017y70c3c729v450cdc3d0c1188de@mail.gmail.com>	 <20081205195624.95ea1866.akpm@linux-foundation.org>	 <493A92FD.3060302@trash.net> <35476bd20812061010g145b6c19r282ae32a4ebfabb1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: m m <olsajiri@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <35476bd20812061010g145b6c19r282ae32a4ebfabb1@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

m m wrote:
> On Sat, Dec 6, 2008 at 3:58 PM, Patrick McHardy <kaber@trash.net> wrote:
>> That doesn't make sense. When you use multicast, multiple applications
>> can be listening to the messages. If you really need state for a single
>> listener and exchange messages in both directions, it sounds like you
>> should use unicast.
>>
>>
> My user app register in kernel for a data. When there is a first
> application request,
> kernel module creates an internal record and ask DATA subsystem for a data,
> which are then passed to the user application.
> 
> The data are then delivered to the application as they are comming from
> the DATA subsystem.
> 
> When there's another application requesting the same data type, kernel module
> just increase reference count in the internal record, and multicast delivers
> data to the other app.
> 
> Now when one of those applications end, kernel module just decrease
> the reference count in the internal record.
> 
> When the other application ends, kernel module needs to release the internal
> record and ask the DATA subsystem to stop delivering data.
> 
> Hope this make sense... I could do some ascii art next time if needed :)

Thats an unusual way to use netlink, but it sounds reasonable.

Adding a notifier for multicast unsubscriptions should be easy.
Nothing in the kernel needs it though, so you need to carry the
patch to do this yourself until you submit your module.
