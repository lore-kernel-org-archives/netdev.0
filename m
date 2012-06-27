From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] udp: Add socket early demux support
Date: Tue, 26 Jun 2012 17:06:29 -0700
Message-ID: <CAGK4HS-bh2_hwiQAM+-4UaD8Ts5NAVEh19nBbAT8fQn1GookSw@mail.gmail.com>
References: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com>
	<20120626.143401.445148198931339546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:61574 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213Ab2F0AG3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 20:06:29 -0400
Received: by ghrr11 with SMTP id r11so508455ghr.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 17:06:29 -0700 (PDT)
In-Reply-To: <20120626.143401.445148198931339546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the reviews and feedback, Dave and Eric. They were very help=
ful.

On 26 June 2012 14:34, David Miller <davem@davemloft.net> wrote:
>
> You can't do this.
>
> If the UDP socket has wildcards, that means the source address of the
> route will not be validated. =A0This means we will start accepting
> spoofed packets. =A0It also means the route you are caching is going
> to be the wrong route since the keys are variable.

Thanks for this explanation.
I see why Eric wanted me to test with DNS server bound to wildcard
address. I guess the same issue exists with multicast too which I had
not even considered.

>
> You can only do an early demux where all the keys are fully specified
> and there are no wildcards. =A0That why for TCP we only early demux f=
or
> established sockets.

I guess for UDP, early demux will work only if server binds to a
specific address and port instead of wildcard. But I believe
a lot of UDP servers use wildcard addresses, so use of early demux for
UDP may be limited.

Thanks,
Vijay
