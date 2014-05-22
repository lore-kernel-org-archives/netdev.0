From: Cong Wang <cwang@twopensource.com>
Subject: Please queue commit e33d0ba8047b049 for stable
Date: Thu, 22 May 2014 14:09:07 -0700
Message-ID: <CAHA+R7OK6aQho_cWC6wy1m9qQqz=i-vmwHmMEL8L6oYTXTkJpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:44101 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbaEVVJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 17:09:08 -0400
Received: by mail-qg0-f43.google.com with SMTP id 63so6824180qgz.30
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 14:09:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David

Please queue the following commit for stable:

commit e33d0ba8047b049c9262fdb1fcafb93cb52ceceb
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Apr 3 09:28:10 2014 -0700

    net-gro: reset skb->truesize in napi_reuse_skb()

    Recycling skb always had been very tough...

    This time it appears GRO layer can accumulate skb->truesize
    adjustments made by drivers when they attach a fragment to skb.

    skb_gro_receive() can only subtract from skb->truesize the used part
    of a fragment.

    I spotted this problem seeing TcpExtPruneCalled and
    TcpExtTCPRcvCollapsed that were unexpected with a recent kernel, where
    TCP receive window should be sized properly to accept traffic coming
    from a driver not overshooting skb->truesize.

    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

unless Eric disagrees.

If I understand it correctly, it  fixes a real bug for all drivers calling
napi_gro_frags(). But I am not sure which version of kernels it should
apply to, it seems to be a long-standing bug.

Thanks!
