From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 9/9] net: sctp: sctp_ulpq: do not use char as
 a struct member
Date: Wed, 17 Apr 2013 17:41:46 +0200
Message-ID: <516EC2BA.5020506@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com> <1366146438-8815-10-git-send-email-dborkman@redhat.com> <516EC197.1080206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965189Ab3DQPlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 11:41:51 -0400
In-Reply-To: <516EC197.1080206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2013 05:36 PM, Vlad Yasevich wrote:
> On 04/16/2013 05:07 PM, Daniel Borkmann wrote:
>> Replace char with a more appropriate __u8 bitfield for pd_mode.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   include/net/sctp/ulpqueue.h | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
>> index 00e50ba..a2bebd4 100644
>> --- a/include/net/sctp/ulpqueue.h
>> +++ b/include/net/sctp/ulpqueue.h
>> @@ -49,10 +49,10 @@
>>
>>   /* A structure to carry information to the ULP (e.g. Sockets API) */
>>   struct sctp_ulpq {
>> -    char pd_mode;
>>       struct sctp_association *asoc;
>>       struct sk_buff_head reasm;
>>       struct sk_buff_head lobby;
>> +    __u8 pd_mode:1;
>>   };
>>
>>   /* Prototypes. */
>
> This one is a bit pointless.  You are not saving any space and making generated code worse.

Right, this one should be dropped, if Dave wants me to resubmit from
0 to 8, I can do that, otherwise just this one can be left out.
