From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/3] L3 RX handler
Date: Sun, 30 Aug 2015 21:59:23 -0600
Message-ID: <55E3D11B.9050303@cumulusnetworks.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
 <1440811867.8932.111.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150828.221417.905062374709400810.davem@davemloft.net>
 <55E1CDCB.2030205@cumulusnetworks.com>
 <CALx6S37JNtd-+A0pCTGGq=4oj_YoVHc0XZpX-tPzv9L8YvmGyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36677 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbHaD70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 23:59:26 -0400
Received: by iod35 with SMTP id 35so15664954iod.3
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2015 20:59:26 -0700 (PDT)
In-Reply-To: <CALx6S37JNtd-+A0pCTGGq=4oj_YoVHc0XZpX-tPzv9L8YvmGyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom:

On 8/29/15 12:02 PM, Tom Herbert wrote:
> To begin with, can we abstract out the need for common code to know
> about the VRF device (netif_index_is_vrf). Looking more closely at
> udp_semdmsg code, there's seems to be some potential problems:

My intention to address your udp_sendmsg comment is to rip out the 
change that was added and set the source address in the VRF device 
driver. Doing so ...

>
> 1) In the VRF case route lookup is being called twice for every
> unconnected packet when going through vrf path :-(
> 2) The "unconnected socket" comment is not incorrect, this path is
> taken for connected sockets also before there is a cache route
> 3) Looks like in VRF path the source address can be arbitrarily
> overwritten in the case that it is non-zero (that is non-zero, but not
> a connect socket).

... fixes the above problems for non-VRF users completely. VRF users 
will still have multiple lookups but that is by design.

David
