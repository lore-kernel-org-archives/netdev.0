From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] tcp: remove the duplicate prefixes in the
 logging message
Date: Thu, 24 Apr 2014 13:26:01 -0400 (EDT)
Message-ID: <20140424.132601.1353360035894164439.davem@davemloft.net>
References: <1398245335-18780-1-git-send-email-roy.qing.li@gmail.com>
	<5357897D.8060809@redhat.com>
	<CAJFZqHxg9YSmHWb9DgmdtO01vVz3vN86DaCNdswRtZviemh3mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, joe@perches.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757496AbaDXR0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:26:03 -0400
In-Reply-To: <CAJFZqHxg9YSmHWb9DgmdtO01vVz3vN86DaCNdswRtZviemh3mQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>
Date: Wed, 23 Apr 2014 21:32:43 +0800

> On Wed, Apr 23, 2014 at 5:35 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 04/23/2014 11:28 AM, roy.qing.li@gmail.com wrote:
>>>
>>> From: Li RongQing <roy.qing.li@gmail.com>
>>>
>>> The current message is:
>>>         TCP: TCP: Possible SYN flooding on port 80. Sending cookies. ...
>>>
>>> The cause is that pr_info will implicitly print the pr_fmt string, which
>>> is standard
>>> prefix, and explicitly print the "proto" which is "TCP:" too
>>>
>>> it is unsuitable to not print proto, since proto maybe TCPv6, so use
>>> printk directly.
>>
>>
>> Can't you just leave the pr_info() instead, and reword that into something
>> like:
>>
>>   "Possible %s SYN flooding[...]", proto
> To ipv4:
> 
> TCP: Possible TCP SYN flooding on port 80. Sending cookies. ...
> 
> To ipv6:
> 
> TCP: Possible TCPv6 SYN flooding on port 80. Sending cookies. ...
> 
> 
> I think there are two "TCP" still, and it is  duplicate;

Just kill the proto string altogether, I don't think it doesn't adds
anything.
