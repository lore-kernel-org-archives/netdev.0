From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 2 Dec 2015 11:18:43 +0530
Message-ID: <CA+sq2CduMnsh_R9zTRMjWT=F5=9U3si-5nO6-gFvGCO9czkDdA@mail.gmail.com>
References: <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
	<1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
	<20151201.143047.82022857078130793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pavel Fedin <p.fedin@samsung.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151201.143047.82022857078130793.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>The driver should successfully recover from out of memory situations
> and not stop RX/TX completely.
This memory allocation is while interface bringup/initialization and not during
packet I/O.

>Don't put this off as not "related" to your patch, it is as this
>introduces the behavior for this user, and you should fix it before
>expecting me to apply this patch series.
I would disagree on this, as this patch hasn't introduced any failure here,
if this user has connected any device which asks for a bit large amount
of coherent memory then i am sure he will see the same issue.
And above i have suggested what could be done to not see this issue.

But anyway for the time being I will resubmit the patch series without this
patch, hope that would be okay.

On Wed, Dec 2, 2015 at 1:00 AM, David Miller <davem@davemloft.net> wrote:
> From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
> Date: Tue, 1 Dec 2015 22:00:49 +0530
>
>> Increasing descriptor ring size will lead to more memory allocation.
>> And what you are seeing is a memory alloc failure and doesn't seem
>> to be due to this driver change.  I mean it looks like the behavior
>> will be same for other drivers as well.
>
> The driver should successfully recover from out of memory situations
> and not stop RX/TX completely.
>
> There might be some other problem with your driver causing this.
>
> Don't put this off as not "related" to your patch, it is as this
> introduces the behavior for this user, and you should fix it before
> expecting me to apply this patch series.
