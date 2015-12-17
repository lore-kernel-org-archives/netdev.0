From: Prashant Upadhyaya <praupadhyaya@gmail.com>
Subject: Re: Load Balancing for AF_INET Raw Sockets
Date: Thu, 17 Dec 2015 14:38:23 +0530
Message-ID: <CAPBAu3Wmj2w_pfcqFeDtXG9BOYF4tuohyCNOOY_B2HgPDf7BrA@mail.gmail.com>
References: <CAPBAu3Uz5P-uJ3Hqg=K49PLDkaGtUWW_SGAH0mTvAsevwvE7Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:32912 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933280AbbLQJIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 04:08:24 -0500
Received: by mail-io0-f172.google.com with SMTP id 186so49258107iow.0
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 01:08:24 -0800 (PST)
In-Reply-To: <CAPBAu3Uz5P-uJ3Hqg=K49PLDkaGtUWW_SGAH0mTvAsevwvE7Ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 6:26 PM, Prashant Upadhyaya
<praupadhyaya@gmail.com> wrote:
> Hi,
>
> I open a raw socket for listening to all the UDP packets in a raw fashion --
>
> socket(AF_INET, SOCK_RAW, IPPROTO_UDP);
>
> Then I use recvfrom to read the packets over the socket.
>
> The above works mighty fine.
> I want to find out if it is possible to 'load balance' the UDP flows
> by opening up multiple instances of this socket and then possibly
> setting some socket options so that I can scale up the reading via
> multiple threads doing recvfrom on these from multiple cores.
> (I know it is possible over packet sockets, but that is a different usecase)
>
> Regards
> -Prashant

ah, the msg_name field in msghdr should do the trick for src address.
