From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2] bonding: add ip checks when store ip target
Date: Thu, 14 Nov 2013 18:23:16 +0800
Message-ID: <5284A494.5020408@huawei.com>
References: <52843700.2040509@huawei.com> <20131114101028.GQ19702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:14997 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab3KNKXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 05:23:55 -0500
In-Reply-To: <20131114101028.GQ19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/14 18:10, Veaceslav Falico wrote:
> On Thu, Nov 14, 2013 at 10:35:44AM +0800, Ding Tianhong wrote:
> ...snip...
>> -    newtarget = in_aton(buf + 1);
>> +    if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL) ||
>> +            newtarget == 0) {
> 
> Good catch on that newtarget verification, forgot to add it. However, the
> previous checked not only for all-zeroes, but also for the broadcast, so
> it'd be great if you could maintain the previous functionality/checks.
> 
> Or, even better, you could do something like SCTP does in
> IS_IPV4_UNUSABLE_ADDRESS():
> 
> 353 #define IS_IPV4_UNUSABLE_ADDRESS(a)         \
> 354         ((htonl(INADDR_BROADCAST) == a) ||  \
> 355          ipv4_is_multicast(a) ||            \
> 356          ipv4_is_zeronet(a) ||              \
> 357          ipv4_is_test_198(a) ||             \
> 358          ipv4_is_anycast_6to4(a))
> 
> It's up to you, though, I think that either way works good - it's
> sysadmin's job to know which addresses can/have to be used.
> 
> Also, fix the identation.
> 
> Thanks!
> 

ok

>> +        pr_err("%s: invalid ARP target %pI4 specified for addition\n",
>> +               bond->dev->name, &newtarget);
>> +        goto out;
>> +    }
>>     /* look for adds */
>>     if (buf[0] == '+') {
>> -        if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
>> -            pr_err("%s: invalid ARP target %pI4 specified for addition\n",
>> -                   bond->dev->name, &newtarget);
>> -            goto out;
>> -        }
>> -
>>         if (bond_get_targets_ip(targets, newtarget) != -1) { /* dup */
>>             pr_err("%s: ARP target %pI4 is already present\n",
>>                    bond->dev->name, &newtarget);
> ...snip...
> 
> .
> 
