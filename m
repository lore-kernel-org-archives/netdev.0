From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net] netconsole: Check for carrier before calling netpoll_send_udp()
Date: Tue, 11 Aug 2015 15:53:18 +1000
Message-ID: <CAGHK07DgBuVk==rJrc2gWa311DCMJK9NdDDk8OJAfRb=YLigBg@mail.gmail.com>
References: <1439256746-7953-1-git-send-email-jmaxwell37@gmail.com>
	<20150810.212256.1658635789817625453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jon Maxwell <jmaxwell@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150810.212256.1658635789817625453.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What if the carrier check passes, and then the chip reset starts on
> another cpu?  You'll have the same problem.

Okay, let me see if I can come up with a better way to mitigate this.

On Tue, Aug 11, 2015 at 2:22 PM, David Miller <davem@davemloft.net> wrote:
> From: Jon Maxwell <jmaxwell37@gmail.com>
> Date: Tue, 11 Aug 2015 11:32:26 +1000
>
>> We have seen a few crashes recently where a NIC is getting
>> reset for some reason and then the driver or another module calls
>> printk() which invokes netconsole. Netconsole then calls the
>> adapter specific poll routine via netpoll which crashes because
>> the adapter is resetting and its structures are being reinitialized.
>
> This isn't a fix.
>
> What if the carrier check passes, and then the chip reset starts on
> another cpu?  You'll have the same problem.
>
> I'm not applying this, sorry.
