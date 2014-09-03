From: Harish Jenny Kandiga Nagaraj <harish_kandiga@mentor.com>
Subject: Re: [RFC PATCH] netlink: Safer deletion of sk_bind_node
Date: Wed, 3 Sep 2014 10:49:59 +0530
Message-ID: <5406A4FF.1090209@mentor.com>
References: <1409555309-5893-1-git-send-email-harish_kandiga@mentor.com>	<20140901.220325.955861172520355423.davem@davemloft.net>	<54058376.9090700@mentor.com> <20140902.115215.1488500321662046816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dborkman@redhat.com>, <tgraf@suug.ch>, <ebiederm@xmission.com>,
	<darkjames-ws@darkjames.pl>, <rgb@redhat.com>,
	<eric.dumazet@gmail.com>, <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140902.115215.1488500321662046816.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If that is the case , then subscriptions of netlink_sock should have been updated after netlink_remove or netlink_release.
I don't see that happening.

On Wednesday 03 September 2014 12:22 AM, David Miller wrote:
> From: Harish Jenny Kandiga Nagaraj <harish_kandiga@mentor.com>
> Date: Tue, 2 Sep 2014 14:14:38 +0530
>
>> In one of our random test runs we observed the crash mentioned in the previous mail.
>>
>> After debugging we found out that the call flow of the inline and static functions were
>> netlink_release
>> -----netlink_remove
>> ---------__sk_del_bind_node
>> --------------__hlist_del
>>
>> *pprev was NULL in __hlist_del function while deleting &sk->sk_bind_node hlist_node. Hence the patch was given.
>>
>> In netlink_remove function , first the sk_del_node_init function will be called. This internally calls __sk_del_node_init function. While deleting &sk->sk_node hlist_node using __sk_del_node function there is a NULL check with sk_hashed function.
>>
>> Why there is no NULL check for *pprev while deleting &sk->sk_bind_node ?
> Because if ->subscriptions is non-zero, it must be on a list, and therefore
> pprev must be non-NULL.
