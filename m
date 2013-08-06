From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2 net-next] ip_tunnel: operstate support and link state transfer
Date: Tue, 6 Aug 2013 10:42:53 -0700
Message-ID: <CALnjE+qQWampgB5OOR54XkbuBe+Hb6p9d15aPvSEAvjxgXqhwQ@mail.gmail.com>
References: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
	<20130805225359.7ba89042@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:43481 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756477Ab3HFRnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 13:43:41 -0400
Received: by mail-qa0-f45.google.com with SMTP id l18so1802169qak.4
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 10:42:57 -0700 (PDT)
In-Reply-To: <20130805225359.7ba89042@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 5, 2013 at 10:53 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Tunnel devices should reflect the carrier state of the lower device.
> I.e if carrier goes down on the lower (ethernet) device, it should
> change on the tunnel as well.
>
> This patch also adds full RFC2863 compatible state so that the
> tunnel state can be controlled from user space as described in
> Documentation/networking/operstats.txt
>
> Example of usage:
> ip li add tnl1 mode dormant \
>   type gretap remote 172.19.20.21 local 172.16.17.18 dev eth1
> ip li set dev tnl1 up
> ip li set dev tnl1 state UP
>
> In real life, this would be managed by tunnel broker, not
> iproute2 shell commands.
>
>
I sent out similar patch which try to add this feature at ip_tunnel
generic layer rather than in tunnel implementation.  This way we can
share single notifier for all tunneling protocols.
Can you have something similar?
http://marc.info/?l=linux-netdev&m=135761231222711&w=2
