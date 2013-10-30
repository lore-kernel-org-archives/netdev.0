From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] r8152: modify the tx flow
Date: Tue, 29 Oct 2013 23:08:56 -0400 (EDT)
Message-ID: <20131029.230856.328906289275539939.davem@davemloft.net>
References: <1383033377-1178-3-git-send-email-hayeswang@realtek.com>
	<20131029.174936.13317032766742363.davem@davemloft.net>
	<7F69554959F74FA58AE07F06B9FCF029@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F69554959F74FA58AE07F06B9FCF029@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: hayeswang <hayeswang@realtek.com>
Date: Wed, 30 Oct 2013 11:03:55 +0800

>  David Miller [mailto:davem@davemloft.net] 
>> Sent: Wednesday, October 30, 2013 5:50 AM
>> To: Hayeswang
>> Cc: netdev@vger.kernel.org; nic_swsd; 
>> linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
>> Subject: Re: [PATCH net 2/3] r8152: modify the tx flow
>> 
>> From: Hayes Wang <hayeswang@realtek.com>
>> Date: Tue, 29 Oct 2013 15:56:16 +0800
>> 
>> > Support stopping and waking tx queue. The maximum tx queue length
>> > is 60.
>> 
>> What is so special about the number 60?  It seems arbitrary, and if
>> it isn't arbitrary you haven't described why this value was choosen.
> 
> The value is arbitrary. I think it is better to stop tx when
> queuing many packets, otherwise all the available memory may
> be used for tx skb. The queue length could be any value or
> unlimited if the memory is enough. Should I remove it?

You should at least pick some value that you have analyzed in some
way.  We've done a lot of work to strongly limit the amount of SKB
data which sits in device queues on transmit, and what you're doing
here works against to those goals.

Ideally you should pick a value which is sufficient to meet two
goals at the same time:

1) With constant transmit traffic coming from the networking stack,
   the device never starves for new transmit data to send.

2) We never queue up more traffic than we need to satisfy requirement
   #1.
