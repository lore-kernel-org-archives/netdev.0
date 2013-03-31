From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: RX/dropped counter values for tagged packets
Date: Sat, 30 Mar 2013 20:30:51 -0700
Message-ID: <CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
References: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linuxdev@anirban.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f180.google.com ([209.85.210.180]:44607 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497Ab3CaDaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 23:30:52 -0400
Received: by mail-ia0-f180.google.com with SMTP id f27so1189209iae.39
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 20:30:51 -0700 (PDT)
In-Reply-To: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

any feedback on this will be highly appreciated.

thanks,

ani


On Sun, Mar 24, 2013 at 9:43 PM, Ani Sinha <ani@aristanetworks.com> wrote:
> hello everyone :
>
> Please bear with me if you think I said something wrong.
>
> I was looking at the netif_receive_skb() code and it seems to me that
> for vlan tagged packets, the counters are manipulated at two different
> places. One is from vlan_do_receive() where the receive counters are
> incremented. The other counter (the dropped counter) is incremented at
> the very end of netif_receive_skb() when there are no takers for this
> packet. The dropped counts are incremented for skb->dev->rx_dropped
> whereas the receive counts are incremented for the vlan device
> specific private stat counter values. When the numbers are reported on
> /proc/net/dev (from where ifconfig gets the numbers), these two stat
> counters are combined together (see dev_get_stats() where rx_dropped
> is added to the device private stat numbers). So if no one is
> receiving the tagged packets, it will be reported both as received and
> dropped! I wonder whether I am analyzing it wrong or whether no one
> has noticed this before or whether this is intentional.
>
> Any  clarification will be greatly appreciated. Again, I could be
> wrong looking at the code, so please bear with me.
>
> Thanks
>
> ani
