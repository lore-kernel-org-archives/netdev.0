From: Ric Wheeler <ric@emc.com>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Thu, 14 Jul 2005 08:27:45 -0400
Message-ID: <42D65A41.7070403__33785.859301179$1121344546$gmane$org@emc.com>
References: <4151C0F9B9C25C47B3328922A6297A3286CFB8@post.arx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yair Itzhaki <Yair@arx.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
        "Chitrapu, Kishore" <Chitrapu_Kishore@emc.com>,
        "Mellors, Andrew" <Mellors_Andrew@emc.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <4151C0F9B9C25C47B3328922A6297A3286CFB8@post.arx.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Patrick, Hebert,

This issues stills seems to be in the latest trees - is this patch or a 
variation on it still bumping around?

Thanks!

Yair Itzhaki wrote:

>Can anyone propose a patch that I can start checking?
>
>I have come up with the following:
>
>--- net/core/netfilter.c.orig   2005-04-18 21:55:30.000000000 +0300
>+++ net/core/netfilter.c        2005-05-02 17:35:20.000000000 +0300
>@@ -622,9 +622,10 @@
>        /* some non-standard hacks like ipt_REJECT.c:send_reset() can cause
>         * packets with foreign saddr to appear on the NF_IP_LOCAL_OUT hook.
>         */
>-       if (inet_addr_type(iph->saddr) == RTN_LOCAL) {
>+       if ((inet_addr_type(iph->saddr) == RTN_LOCAL) ||
>+           (inet_addr_type(iph->daddr) == RTN_LOCAL)) {
>                fl.nl_u.ip4_u.daddr = iph->daddr;
>-               fl.nl_u.ip4_u.saddr = iph->saddr;
>+               fl.nl_u.ip4_u.saddr = 0;
>                fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
>                fl.oif = (*pskb)->sk ? (*pskb)->sk->sk_bound_dev_if : 0;
> #ifdef CONFIG_IP_ROUTE_FWMARK
>
>Please advise,
>Yair
>
>
>  
>
>>-----Original Message-----
>>From: Patrick McHardy [mailto:kaber@trash.net]
>>Sent: Wednesday, April 27, 2005 14:05
>>To: Herbert Xu
>>Cc: Jozsef Kadlecsik; netdev@oss.sgi.com; 
>>netfilter-devel@lists.netfilter.org; Yair Itzhaki; 
>>linux-kernel@vger.kernel.org
>>Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
>>
>>
>>Herbert Xu wrote:
>>    
>>
>>>Here is another reason why these packets should go through FORWARD.
>>>They were generated in response to packets in INPUT/FORWARD/OUTPUT.
>>>The original packet has not undergone SNAT in any of these cases.
>>>
>>>However, if we feed the response packet through LOCAL_OUT it will
>>>be subject to DNAT.  This creates a NAT asymmetry and we may end
>>>up with the wrong destination address.
>>>
>>>By pushing it through FORWARD it will only undergo SNAT which is
>>>correct since the original packet would have undergone DNAT.
>>>      
>>>
>>This is only a problem since the recent NAT changes, but I agree
>>that we should fix it by moving these packets to FORWARD.
>>
>>Regards
>>Patrick
>>
>>    
>>
>
>  
>
