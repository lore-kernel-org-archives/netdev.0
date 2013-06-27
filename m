From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC Patch net-next 2/5] net: introduce generic inet_pton()
Date: Fri, 28 Jun 2013 02:30:10 +0400
Message-ID: <51CCBCF2.5050007@cogentembedded.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com> <1372315398-19683-3-git-send-email-amwang@redhat.com> <51CC49C7.9010800@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CC49C7.9010800@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2013 06:18 PM, Sergei Shtylyov wrote:

>> Signed-off-by: Cong Wang <amwang@redhat.com>
>> ---
>>   include/net/inet_addr.h |   20 ++++++++++++++++++++
>>   net/core/netpoll.c      |   24 ++----------------------
>>   2 files changed, 22 insertions(+), 22 deletions(-)

>> diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
>> index 66a16fe..1379287 100644
>> --- a/include/net/inet_addr.h
>> +++ b/include/net/inet_addr.h
[...]
>> @@ -59,4 +60,23 @@ static inline bool inet_addr_multicast(const union
>> inet_addr *ipa)
>>   }
>>   #endif
>>
>> +static inline int inet_pton(const char *str, union inet_addr *addr)
>> +{
>> +    const char *end;
>> +
>> +    if (!strchr(str, ':') &&
>> +        in4_pton(str, -1, (void *)addr, -1, &end) > 0) {
>> +        if (!*end)
>> +            return 0;
>> +    }
>> +    if (in6_pton(str, -1, addr->sin6.sin6_addr.s6_addr, -1, &end) > 0) {
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +        if (!*end)

>     How about:

>          if (IS_ENABLED(CONFIG_IPV6) && !*end)

>> +            return 1;
>> +#else

    Sorry, managed to miss #else... #if could be avoided anyway, tho 
this could require an extra patch.

>> +        return -1;
>> +#endif
>> +    }
>> +    return -1;
>> +}
>>   #endif

WBR, Sergei
