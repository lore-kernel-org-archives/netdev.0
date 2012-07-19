From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 3/7] net-tcp: Fast Open client - sending SYN-data
Date: Thu, 19 Jul 2012 19:57:51 +0200
Message-ID: <1342720671.2626.4650.camel@edumazet-glaptop>
References: <1342716191-19196-1-git-send-email-ycheng@google.com>
	 <1342716191-19196-4-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:52335 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2GSR56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:57:58 -0400
Received: by vcbfk26 with SMTP id fk26so2225536vcb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:57:57 -0700 (PDT)
In-Reply-To: <1342716191-19196-4-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 09:43 -0700, Yuchung Cheng wrote:
> This patch implements sending SYN-data in tcp_connect(). The data is
> from tcp_sendmsg() with flag MSG_FASTOPEN (implemented in a later patch).
> 
> The length of the cookie in tcp_fastopen_req, init'd to 0, controls the
> type of the SYN. If the cookie is not cached (len==0), the host sends
> data-less SYN with Fast Open cookie request option to solicit a cookie
> from the remote. If cookie is not available (len > 0), the host sends
> a SYN-data with Fast Open cookie option. If cookie length is negative,
>   the SYN will not include any Fast Open option (for fall back operations).
> 
> To deal with middleboxes that may drop SYN with data or experimental TCP
> option, the SYN-data is only sent once. SYN retransmits do not include
> data or Fast Open options. The connection will fall back to regular TCP
> handshake.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/linux/snmp.h  |    1 +
>  include/linux/tcp.h   |    6 ++-
>  include/net/tcp.h     |    9 ++++
>  net/ipv4/af_inet.c    |   10 +++-
>  net/ipv4/proc.c       |    1 +
>  net/ipv4/tcp_output.c |  115 +++++++++++++++++++++++++++++++++++++++++++++----
>  6 files changed, 130 insertions(+), 12 deletions(-)

Eric Dumazet <edumazet@google.com>
