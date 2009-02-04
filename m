From: Andy Fleming <afleming@gmail.com>
Subject: Re: IXP4xx networking and phylib
Date: Wed, 4 Feb 2009 17:15:43 -0600
Message-ID: <2acbd3e40902041515p2624765bx5019c59c2b028780@mail.gmail.com>
References: <200901121705.07966.post@hendrik-sattler.de>
	 <m3wsd0a0k3.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Hendrik Sattler <post@hendrik-sattler.de>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:54143 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625AbZBDXPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 18:15:51 -0500
Received: by qyk4 with SMTP id 4so3822836qyk.13
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2009 15:15:44 -0800 (PST)
In-Reply-To: <m3wsd0a0k3.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 11:36 AM, Krzysztof Halasa <khc@pm.waw.pl> wrote:
> Hi,
>
> Added CC: netdev.
>
> Hendrik Sattler <post@hendrik-sattler.de> writes:
>
>> My IXP465 MII port is connected to a Marvell switch (port 5). This port
>> is "always on" and has no PHY registers. It is configured in hardware. The
>> switch ports 1-4 have phy registers but that's not the matter.
>> The problem is that there is no standard way in the platform info to tell the
>> driver (now phylib) that there are _no_ PHY registers.
>>
>> Is there a standard way to say: enable the ethernet interface and be done with
>> it?
>> I currently do this by patching the driver. The PHYLIB patch makes that even
>> easier but it would be better to not need patching at all (at least one
>> driver less to patch).

There is a "fixed-phy" driver.  It allows you to configure things such
that phylib will treat a PHY at a given address like it is a PHY with
whatever attributes you choose.  The other option is to look at the
DSA code from Lennert, and make the Marvell switch work with that (I
haven't looked closely enough to see if that's feasible, but the end
goal should be that all such integrated switches are covered by some
framework).

Andy
