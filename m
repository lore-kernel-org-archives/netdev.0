From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add vlan id to mdb notifications
Date: Wed, 26 Nov 2014 12:40:06 -0800
Message-ID: <54763AA6.4000804@cumulusnetworks.com>
References: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com> <20141126105614.6a42d697@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, sashok@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:35822 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbaKZUkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:40:10 -0500
In-Reply-To: <20141126105614.6a42d697@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14, 10:56 AM, Stephen Hemminger wrote:
> On Wed, 26 Nov 2014 05:53:33 -0800
> roopa@cumulusnetworks.com wrote:
>
>> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
>> index da17e45..db061fd 100644
>> --- a/include/uapi/linux/if_bridge.h
>> +++ b/include/uapi/linux/if_bridge.h
>> @@ -185,6 +185,7 @@ struct br_mdb_entry {
>>   			struct in6_addr ip6;
>>   		} u;
>>   		__be16		proto;
>> +		__be16		vid;
>>   	} addr;
>>   };
>>   
> You can't add fields to existing binary API

Ack,  we know the concern..., The fact that it was not changing the size 
of the struct (due to existing padding and i verified that it worked 
with an older iproute2), we wanted to get the patch out and get some 
feedback.

Getting the vlan in the notification is imp and the only other option I 
see is to add a new netlink attribute in the mdb msg.

I have always wondered, if binary netlink attributes have this 
restriction, they should be discouraged. especially when the other 
extensible option is to add them as a separate netlink attribute.

Thanks for the review.
