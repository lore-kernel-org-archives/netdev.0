From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 11:50:31 -0400
Message-ID: <5231E2C7.1010106@redhat.com>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>   <1378995112.24408.4.camel@edumazet-glaptop>   <CAA7+ByWJLUkxy7C0frKOFUscJaQyRLsfk_N=NZfdzUrbZ=4MNA@mail.gmail.com>  <1378996396.24408.8.camel@edumazet-glaptop> <5231D2D2.3090907@redhat.com> <1378999470.24408.10.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hong zhi guo <honkiko@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, zhiguohong@tencent.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab3ILPvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 11:51:05 -0400
In-Reply-To: <1378999470.24408.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2013 11:24 AM, Eric Dumazet wrote:
> On Thu, 2013-09-12 at 10:42 -0400, Vlad Yasevich wrote:
>
>> Don't all tests for IFF_BRIDGE_PORT on the bridge receive path become
>> redundant as well?
>
> Sure but anyway this part is net-next material
>
> Lets fix the bug first.

Seems like the race is possible in net as well.  If we just include the
original patch, then br_add_if() also has to be modified to make sure
the flag is set properly before netdev_rx_handler_register() is called.

If we remove the need to check the flag during bridge input handling,
then br_add_if() change is not necessary.

-vlad

>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
