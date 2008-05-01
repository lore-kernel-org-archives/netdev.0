From: "prodyut hazarika" <prodyuth@gmail.com>
Subject: State of TCP segmentation offload to NIC in linux
Date: Thu, 1 May 2008 10:56:10 -0700
Message-ID: <49c0ff980805011056q25d24616vf4cea6d8b387b717@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:52041 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbYEAR4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 13:56:14 -0400
Received: by fg-out-1718.google.com with SMTP id 19so628663fgg.17
        for <netdev@vger.kernel.org>; Thu, 01 May 2008 10:56:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I am trying to understand the current state of TCP segmentation
offload to Network cards. in Linux I have read posts that tells that
Intel e1000 driver supports TSO (TCP segmentation offload). This link
tells that TSO is supported in Linux:
http://lwn.net/Articles/9129/

 I see the define NETIF_F_TSO in the linux kernel, and I see that the
e1000 driver is setting this flag in its capabilities list. But for
TSO to work, TCP code should send the big segment (say 64K) directly
to the NIC, bypassing the IP layer. Else, the IP layer would fragment
the packets, and the whole purpose of TSO will be lost. I cannot see
any code in tcp layer which bypasses the IP layer and goes directly to
the NIC. It seems to me that the TCP/IP stack in Linux always does the
segmentation, since there is no code under the NETIF_F_TSO define
which bypasses the IP layer. Or am I missing something?

Can anyone please tell me whether the Linux TCP/IP stack support TSO
so that TCP segments bigger than MSS is segmented by the NIC, not the
software? If not, is there plans to support this, since this is
stateless offload?

Any pointers would be greatly appreciated.

Regards,
Prodyuthttp://lwn.net/Articles/9129/

 I see the define NETIF_F_TSO in the linux kernel, and I see that the
e1000 driver is setting this flag in its capabilities list. But for
TSO to work, TCP code should send the big segment (say 64K) directly
to the NIC, bypassing the IP layer. Else, the IP layer would fragment
the packets, and the whole purpose of TSO will be lost. I cannot see
any code in tcp layer which bypasses the IP layer and goes directly to
the NIC. It seems to me that the TCP/IP stack in Linux always does the
segmentation, since there is no code under the NETIF_F_TSO define
which bypasses the IP layer. Or am I missing something?

Can anyone please tell me whether the Linux TCP/IP stack support TSO
so that TCP segments bigger than MSS is segmented by the NIC, not the
software? If not, is there plans to support this, since this is
stateless offload?

Any pointers would be greatly appreciated.

Regards,
Prodyut
