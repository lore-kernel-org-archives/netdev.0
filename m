From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] rds: avoid calling sock_kfree_s() on allocation failure
Date: Tue, 14 Oct 2014 14:27:00 -0700
Message-ID: <CAHA+R7MOAKdyrhS3eaxkfou+xKZmQ_DzzdjdEjV3yszdnjQtNA@mail.gmail.com>
References: <1413315308-32288-1-git-send-email-xiyou.wangcong@gmail.com>
	<20141014.170311.2104285680542945400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, rds-devel@oss.oracle.com,
	chien.yen@oracle.com,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:44833 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbaJNV1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:27:01 -0400
Received: by mail-qa0-f50.google.com with SMTP id w8so6602923qac.9
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 14:27:01 -0700 (PDT)
In-Reply-To: <20141014.170311.2104285680542945400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2014 at 2:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 14 Oct 2014 12:35:08 -0700
>
>> From: Cong Wang <cwang@twopensource.com>
>>
>> It is okay to free a NULL pointer but not okay to mischarge the socket optmem
>> accounting. Compile test only.
>>
>> Reported-by: rucsoftsec@gmail.com
>> Cc: Chien Yen <chien.yen@oracle.com>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Cong Wang <cwang@twopensource.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Applied, and I'm going to add the following bug check to the tree too.
>
> ====================
> [PATCH] net: Trap attempts to call sock_kfree_s() with a NULL pointer.
>
> Unlike normal kfree() it is never right to call sock_kfree_s() with
> a NULL pointer, because sock_kfree_s() also has the side effect of
> discharging the memory from the sockets quota.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>


Acked-by: Cong Wang <cwang@twopensource.com>

Sounds reasonable. It could catch more bugs similar to this one.

Thanks!
