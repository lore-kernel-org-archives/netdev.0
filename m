From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Change in IPv4 TCP reset behavior after kernel upgrade
Date: Wed, 4 Dec 2013 10:15:00 -0500
Message-ID: <CADVnQynL6=91zAZXMAoKEeCY7=Eajfq1DyP+Dzd8xhzBhujtyQ@mail.gmail.com>
References: <2ECE9D9EEF1F524185270138AE2326593BF9B5EE@S0MSMAIL112.arc.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fiedler Roman <Roman.Fiedler@ait.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:50342 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718Ab3LDPPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 10:15:02 -0500
Received: by mail-ee0-f42.google.com with SMTP id e53so1489856eek.29
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 07:15:01 -0800 (PST)
In-Reply-To: <2ECE9D9EEF1F524185270138AE2326593BF9B5EE@S0MSMAIL112.arc.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 4, 2013 at 5:09 AM, Fiedler Roman <Roman.Fiedler@ait.ac.at> wrote:
> Hello,
>
> After upgrading from linux-image-3.10.17 to linux-image-3.10.21 I noticed, that afterwards reset packets started to be transmitted with ID != 0. For testing:
>
> tcpdump -i eth0 -nn -s0 -X -vvv 'tcp[tcpflags] & tcp-rst != 0'
>
> I did a short search to find out when and why this was changed (PATCH), but did not get any wiser.
>
> Was this an intended change, e.g. to increase resilience against RST-packet injection/DOS scenarios? Is it just accidentally?
>
> The ID seems to be in sequence, so it is not uninitialized memory content.
>
> Roman
>
> PS: The kernel was patched with the vserver-patch, this might have an influence. I did not have time yet to build a kernel without that modification.

One possibly related commit would be:

ip: generate unique IP identificator if local fragmentation is allowed
703133de331a7a7df47f31fb9de51dc6f68a9de8

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=703133de331a7a7df47f31fb9de51dc6f68a9de8

But that went into 3.10.16, which is one release outside the window
you mention....

neal
