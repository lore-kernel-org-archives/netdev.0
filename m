From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kmod: don't load module unless req process has
 CAP_SYS_MODULE
Date: Mon, 15 May 2017 09:52:28 -0400 (EDT)
Message-ID: <20170515.095228.1483686375235860235.davem@davemloft.net>
References: <20170514104537.GA29323@kroah.com>
        <87d1bbo81d.fsf@xmission.com>
        <20170515061059.GB28741@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, mahesh@bandewar.net, mingo@kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        keescook@chromium.org, edumazet@google.com, maheshb@google.com
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515061059.GB28741@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 15 May 2017 08:10:59 +0200

> On Sun, May 14, 2017 at 08:57:34AM -0500, Eric W. Biederman wrote:
>> Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:
>> 
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index bcb0f610ee42..6b72528a4636 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2595,7 +2595,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
>>  
>>                 if (!ops) {
>>  #ifdef CONFIG_MODULES
>> -                       if (kind[0]) {
>> +                       if (kind[0] && capable(CAP_NET_ADMIN)) {
>>                                 __rtnl_unlock();
>>                                 request_module("rtnl-link-%s", kind);
>>                                 rtnl_lock();
> 
> I don't object to this if the networking developers don't mind the
> change in functionality.  They can handle the fallout :)

As I've said in another email, I am pretty sure this can break things.
