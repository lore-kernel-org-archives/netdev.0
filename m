From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 07:33:16 -0700
Message-ID: <1378996396.24408.8.camel@edumazet-glaptop>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	 <1378995112.24408.4.camel@edumazet-glaptop>
	 <CAA7+ByWJLUkxy7C0frKOFUscJaQyRLsfk_N=NZfdzUrbZ=4MNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	zhiguohong@tencent.com
To: Hong zhi guo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:41367 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab3ILOdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 10:33:18 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so1181841pad.4
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 07:33:17 -0700 (PDT)
In-Reply-To: <CAA7+ByWJLUkxy7C0frKOFUscJaQyRLsfk_N=NZfdzUrbZ=4MNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 22:24 +0800, Hong zhi guo wrote:
> You mean IFF_BRIDGE_PORT should be only for admin/control path, but
> not for data path?

By definition, br_handle_frame() should be called only when device is a
bridge port.

After the call to synchronize_net() included in
netdev_rx_handler_unregister(), you have guarantee br_handle_frame()
wont be called.

Therefore, testing IFF_BRIDGE_PORT in br_handle_frame() is redundant.
