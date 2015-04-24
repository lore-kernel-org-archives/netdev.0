From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Resource usages in Linux drivers
Date: Thu, 23 Apr 2015 17:40:12 -0700
Message-ID: <553990EC.1030401@gmail.com>
References: <5538950F.3040405@163.com> <5538B938.9060607@cogentembedded.com> <5538BB61.30907@163.com> <5538C4A3.6080302@163.com> <5538CB50.3010601@cogentembedded.com> <20150423231917.GA16450@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jia-Ju Bai <baijiaju1990@163.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	stephen@networkplumber.org, Neil Horman <nhorman@tuxdriver.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34091 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbbDXAlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 20:41:25 -0400
Received: by pdbqa5 with SMTP id qa5so32853065pdb.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 17:41:25 -0700 (PDT)
In-Reply-To: <20150423231917.GA16450@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/04/15 16:19, Francois Romieu wrote:
> Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> :
>> On 4/23/2015 1:08 PM, Jia-Ju Bai wrote:
> [...]
>>> I also find many drivers do not use these managed APIs, especially in ethernet
>>> card drivers (like e100, r8169). Is it possible to change them?
>>
>>    Patches welcome. :-)
> 
> I respectfully disagree.

Me too, most of the device managed conversions we have seen were bogus
because they were done in a semi-automated way without understanding the
peculiarities of the network devices, that is the separation between
init/open/close that most other device drivers do not have.

A typical example is this:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6892b41d9701283085b655c6086fb57a5d63fa47

> 
> If someone believes basic resouce management to be too hard or error-prone
> to handle, he should imvho seriously rise the bar and reconsider the way
> he wants to contribute to the kernel.

Well, for one, we could have a device managed register_netdev() which
cleans up resources in case of failures and calls free_netdev()
automatically, but is that adding much value?

> 
> I may hope he who reads e100.c to think about DMA api, bql or rx ring
> holes avoidance to quote a few ones. Managed API ? Mildly...
> 


-- 
Florian
