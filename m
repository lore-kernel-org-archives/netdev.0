From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: query: tcpdump versus atomic?
Date: Wed, 14 Oct 2009 16:36:36 -0400
Message-ID: <4AD63654.6050200@gmail.com>
References: <4AD5522B.50101@gmail.com>	<4AD5EC2C.6070005@gmail.com> <20091014085941.6897d9d9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:37898 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933724AbZJNUi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 16:38:29 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1580068fga.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 13:36:40 -0700 (PDT)
In-Reply-To: <20091014085941.6897d9d9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 14 Oct 2009 11:20:12 -0400
> William Allen Simpson <william.allen.simpson@gmail.com> wrote:
> 
>> William Allen Simpson wrote:
>>> Anybody know what code path tcpdump changes to running atomic?
>>>
>>> Is there a function to test whether you're running atomic?
>>>
>> To partially answer my own question, after laboriously #if'ing compiling
>> section by section, it affects the tcp_minisockets.c code at
>> tcp_create_openreq_child().
>>
>> I've not found a function to test.  I've found sk->sk_allocation, but
>> that doesn't seem to be dynamically updated to reflect the current state.
>>
> did you look at your ethernet's drivers code to turn on promiscuous mode.
> It could be leaving irq's or bottom half disabled.
> 
[    2.876485] eth0: RealTek RTL8139 at 0x2000, 00:40:2b:6b:61:36, IRQ 17
[    2.876490] eth0:  Identified 8139 chip type 'RTL-8101'

No idea on the driver file name, but that's a fairly popular chipset, so
the code should be fairly well reviewed.

Still, tcp shouldn't be processed with interrupts disabled.  That's *way*
too much code....

And we need a function that tells us whether we're atomic already....  And
better function header descriptions that mention the assumptions.
