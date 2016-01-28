From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Thu, 28 Jan 2016 15:10:51 +0100
Message-ID: <56AA216B.3040105@cumulusnetworks.com>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
 <20160128133350.GA2231@nanopsycho.orion>
 <56AA1D65.2000509@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>,
	=?UTF-8?Q?Bj=c3=b8rnar_Ness?= <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38751 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbcA1OKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 09:10:53 -0500
Received: by mail-wm0-f51.google.com with SMTP id p63so26281146wmp.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 06:10:53 -0800 (PST)
In-Reply-To: <56AA1D65.2000509@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2016 02:53 PM, Nikolay Aleksandrov wrote:
> On 01/28/2016 02:33 PM, Jiri Pirko wrote:
>> Mon, Jan 25, 2016 at 05:24:48PM CET, bjornar.ness@gmail.com wrote:
>>> As subject says, 802.3ad bonding is not working with virtio network model.
>>>
>>> The only errors I see is:
>>>
>>> No 802.3ad response from the link partner for any adapters in the bond.
>>>
>>> Dumping the network traffic shows that no LACP packets are sent from the
>>> host running with virtio driver, changing to for example e1000 solves
>>> this problem
>>> with no configuration changes.
>>>
>>> Is this a known problem?
> Can you show your bond's /proc/net/bonding/bond<X> ? And also in order to
> better see what's going on I'd suggest enabling the pr_debug() calls in the 3ad
> code:
> echo 'file bond_3ad.c +p' > /sys/kernel/debug/dynamic_debug/control
> (assuming you have debugfs mounted at /sys/kernel/debug)
> Then you can follow the logs to see what's going on.
> I can clearly see LACP packets sent over virtio net devices:
> 14:53:05.323490 52:54:00:51:25:3c > 01:80:c2:00:00:02, ethertype Slow Protocols (0x8809), length 124: LACPv1, length 110
Nevermind my message, Jiri was right. My setup wasn't correct.
I have a virtio_net get_settings hack that enables me to test 802.3ad over virtio_net
locally.
Sorry about the noise.

> 
>>
>> I believe the problem is virtio_net for obvious reasons does not report
>> speed and duplex. Bonding 3ad mode makes that unconfortable :)
[snip]
Right, of course. My setup has some patches that add get_settings to virtio_net
to make it play nice for testing 803.2ad.

>>
>> Use team ;)
> 
:-)
