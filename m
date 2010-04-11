From: Cristian KLEIN <cristiklein@gmail.com>
Subject: Re: [PATCH] tcp: add setsockopt to disable slow start after idle
Date: Sun, 11 Apr 2010 20:45:10 +0200
Message-ID: <4BC218B6.8050703@gmail.com>
References: <1270863015-19597-1-git-send-email-cristiklein@gmail.com>	<20100409.221307.246951787.davem@davemloft.net>	<4BC06A5F.6070804@gmail.com> <20100410.154709.201110995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59249 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab0DKSpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 14:45:17 -0400
In-Reply-To: <20100410.154709.201110995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2010 00:47, David Miller wrote:
> From: Cristian KLEIN<cristiklein@gmail.com>
> Date: Sat, 10 Apr 2010 14:09:03 +0200
>
>> Could you please explain me why it is dangerous? To me it seems that
>> it's just like allowing applications to disable NAGLE or to choose a
>> congestion control algorithm.
>
> Because you can cause undue congestion to other people on the network
> because you are believing path information that has been outdated and
> has not been validated by sending data for a certain amount of time.

I consider your argument an important concern, but I'm not quite 
convinced this patch is so bad.

An application which does not need this behaviour will continue to slow 
start after idle by default.

Without this patch, an application which needs this behaviour (i.e. not 
to slow start after idle) is forced to implement its own UDP-based 
protocol with all the congestion control, retransmission etc. Undue 
congestion might still occur.


If you don't agree with the above two points, would you consider 
accepting a patch with an allow_user_fast_start_after_idle sysctl?

Cristi.
