From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: IPV6 source routing patch is still broken?
Date: Thu, 26 Apr 2007 18:57:06 -0400
Message-ID: <46312E42.4070204@redhat.com>
References: <46311F76.9040803@redhat.com> <20070426.153142.57441302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Sergey Vlasov <vsu@altlinux.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47759 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031511AbXDZW5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 18:57:15 -0400
In-Reply-To: <20070426.153142.57441302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> +       case IPV6_SRCRT_TYPE_2:
>> +               if (accept_source_route >= 0)
>> +                       break;
>> +               kfree_skb(skb);
>> +               return -1;
>> +       case IPV6_SRCRT_TYPE_0:
>> +               if (accept_source_route > 0)
>> +                       break;
>> +               kfree_skb(skb);
>> +               return -1;
> 
> Yes, that looks like it matches the sysctl documentation more closely:
> 
> accept_source_route - INTEGER
> 	Accept source routing (routing extension header).
> 
> 	> 0: Accept routing header.
> 	= 0: Accept only routing header type 2.
> 	< 0: Do not accept routing header.
> 
> Type 2 packets should get through as long as the value of the sysctl
> is not negative.

It was Sergey Vlasov who first found this. I had tried to find his original
message but I was searching the wrong place.

Sergey, you should send networking-related messages to netdev.

