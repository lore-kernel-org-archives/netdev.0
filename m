From: Patrick McHardy <kaber@trash.net>
Subject: Re: More tc action mess
Date: Wed, 19 Jan 2005 21:22:51 +0100
Message-ID: <41EEC19B.3010504@trash.net>
References: <41EDEB97.3080503@trash.net> <1106140256.1049.903.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1106140256.1049.903.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Wed, 2005-01-19 at 00:09, Patrick McHardy wrote:
>  
>
>>This means we must convert all paths on which tcf_action_exec is called
>>to use struct sk_buff ** :(
>>    
>>
> 
>
>No, just restore the code that you took out in one of your patches
>right above that line which reads:
>
>----
>        if (skb_cloned(skb)) {
>                if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
>                        return -1;
>                }
>        }
>----
>
>Depending on what you do in netfilter lately, you may wanna take out
>the skb_cloned() call.
>  
>

This does not help. Netfilter calls skb_ip_make_writable if it has to
touch the packet, if it is shared or cloned the packet will be copied.
Despite this, this is hardly a fix as long as the ->act function takes
a struct sk_buff **.

Regards
Patrick
