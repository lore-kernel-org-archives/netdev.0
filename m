From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 10:42:26 -0400
Message-ID: <5231D2D2.3090907@redhat.com>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>  <1378995112.24408.4.camel@edumazet-glaptop>  <CAA7+ByWJLUkxy7C0frKOFUscJaQyRLsfk_N=NZfdzUrbZ=4MNA@mail.gmail.com> <1378996396.24408.8.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hong zhi guo <honkiko@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, zhiguohong@tencent.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752053Ab3ILOmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 10:42:49 -0400
In-Reply-To: <1378996396.24408.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2013 10:33 AM, Eric Dumazet wrote:
> On Thu, 2013-09-12 at 22:24 +0800, Hong zhi guo wrote:
>> You mean IFF_BRIDGE_PORT should be only for admin/control path, but
>> not for data path?
>
> By definition, br_handle_frame() should be called only when device is a
> bridge port.
>
> After the call to synchronize_net() included in
> netdev_rx_handler_unregister(), you have guarantee br_handle_frame()
> wont be called.
>
> Therefore, testing IFF_BRIDGE_PORT in br_handle_frame() is redundant.

Don't all tests for IFF_BRIDGE_PORT on the bridge receive path become 
redundant as well?

-vlad

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
