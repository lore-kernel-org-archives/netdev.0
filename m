From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC] sh_eth: use RNC mode for R8A7790
Date: Fri, 28 Mar 2014 23:38:31 +0300
Message-ID: <5335DDC7.8040400@cogentembedded.com>
References: <1396025185-7911-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, magnus.damm@opensource.se,
	nobuhiro.iwamatsu.yj@renesas.com
To: Ben Dooks <ben.dooks@codethink.co.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:44809 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbaC1Ti1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 15:38:27 -0400
Received: by mail-la0-f46.google.com with SMTP id hr17so4023252lab.5
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 12:38:26 -0700 (PDT)
In-Reply-To: <1396025185-7911-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/28/2014 07:46 PM, Ben Dooks wrote:

> The current behaviour of the sh_eth driver is not to use the RNC bit
> for the receive ring. This means that every packet recieved is not only
> generating an IRQ but it also stops the receive ring DMA as well until
> the driver re-enables it after unloading the packet.

> This means that a number of the following errors are generated due to
> the receive packet FIFO overflowing due to nowhere to put packets:

> 	net eth0: Receive FIFO Overflow

> Setting the RMCR_RNC configuration has so far been tested with an NFS
> root filesystem and the driver has not failed yet. It is not yet known
> why this is not set for R8A779x operation

    The reason is simple: it's not set on almost all 100 Mbs devices except 
SH7757 (and most recently added R7S72100), so this was a matter of copy-paste. 
I've had setting this bit on at least R-Car devices on my aganda for some time 
but couldn't get to it yet.

> (Feedback on this issue or other testing is welcome)

    OK, I'll try it with netperf UDP test known to generate handful of the 
aforementioned errors, when I have time.

WBR, Sergei
