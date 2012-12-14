From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Fri, 14 Dec 2012 08:57:23 +0100
Message-ID: <50CADBE3.5060901@onera.fr>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr> <20121213132916.GB10703@netboy.at.omicron.at> <50C9FEC4.5050804@onera.fr> <20121213181733.GA2312@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:52359 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab2LNH77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 02:59:59 -0500
In-Reply-To: <20121213181733.GA2312@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/13/2012 07:17 PM, Richard Cochran wrote:
> On Thu, Dec 13, 2012 at 05:13:56PM +0100, Paul Chavent wrote:
>>>
>>> In order for time stamps to appear, somebody has to call
>>> skb_tx_timestamp() ...
>> Yes. "Somebody" means "the hardware driver" after completing xmit.
>> That's true ?
>
> Yes, the MAC driver must call this helper function, but not many
> drivers do this yet. You didn't say which MAC driver you are using and
> whether it supports Tx SO_TIMESTAMPING or not.
I'm using the uml net device (which recently gains tx timestamping), 
e1000e (wich seems to support it according to my tests), and arm macb 
(wich seems to support it too).


>
>> Yes, it only sets some flags. I thought that those flags was
>> required by the skb_tx_timestamp() in order to make the appropriate
>> timestamping (hardware, software, etc).
>>
>> So in order to have tx timestamp that work, both calls are needed ?
>
> Yes.
>
>> Why sock_tx_timestamp is called in packet_fill_skb and
>> packet_sendmsg_spkt and not in tpacket_fill_skb ?
>> Why i can retrieve timestamps when i add this call ?
>
> Sorry, I don't know much about packet mmap. Last time I tried it, some
> years ago, it wasn't really working.

I haven't measured the performance, but it works for me (however, not on 
my arm platfrom yet).

>
> Richard
>

The af_packet implementation contains 3 "paths" for packets. Perhaps i'm 
a bit confused by its complexity.

Paul.
