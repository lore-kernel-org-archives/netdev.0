From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Tue, 25 Oct 2011 09:57:00 +0200
Message-ID: <CAPXgP11UEm49edrsyP3pD2HPNZCGRgGTWjSyw5VoqwsQT-UmOw@mail.gmail.com>
References: <20111024013406.GA24158@shutemov.name> <20111023.232416.1038111296509565828.davem@davemloft.net>
 <20111024042400.GA31344@shutemov.name> <20111024.005900.1091819103500072631.davem@davemloft.net>
 <CAPXgP10PZU+xSbQW-CH-E5rCk3-=1k-AvAs=tF8fAnz7QsmJRw@mail.gmail.com> <4EA5FA9B.5050908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, kirill@shutemov.name,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, gregkh@suse.de
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49931 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006Ab1JYH5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 03:57:20 -0400
Received: by ggnb1 with SMTP id b1so239041ggn.19
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 00:57:20 -0700 (PDT)
In-Reply-To: <4EA5FA9B.5050908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 25, 2011 at 01:54, Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
> 24.10.2011 16:46, Kay Sievers wrote:
>> Kirill, what exactly is the use case? And why what does udev support
>> mean in that context?
>>
>> I doubt that "not having /sbin/ip installed" should be a reason to add
>> and expose complex interfaces in /sys, while we already have a
>> perfectly working native way to do it.
>
> Adding NETLINK_ROUTE in udev is a way to perform some actions in case
> of network events without polling. Now there are only a few specific
> daemons (NM, connman etc) that are listen to the netlink socket and
> setup the network his own way.

I'm not really convinced that udev should be in charge of network
config changes, it's a really complex area. Udev is a generic kernel
device manager, not a network setup manager.

Our point of view is, that all services depending on network state
changes should listen to netlink themselves, and not be worked around
with tools like udev to execute stuff and notify them.

But again, what's the use-case for that you have in mind?

Kay
