From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.6.11-rc2 TCP ignores PMTU ICMP (Re: Linux 2.6.11-rc2)
Date: Mon, 31 Jan 2005 17:13:36 -0500
Message-ID: <41FEAD90.6060403@tmr.com>
References: <20050127154150.360f95e2.davem@davemloft.net><20050127154150.360f95e2.davem@davemloft.net> <41F99656.5040304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        David Brownell <david-b@pacbell.net>,
        jf-ml-k1-1087813225@lk8rp.mail.xeon.eu.org,
        david+challenge-response@blue-labs.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, ahaas@airmail.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41F99656.5040304@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> David S. Miller wrote:
> 
>> I've forwarded this to netfilter-devel for inspection.
>> Thanks for collecting all the data points so well.
>>
> Here is the fix for everyone. Please report back if it doesn't
> solve the problem. Thanks.

Worked here.
> 
> 
> 
> ------------------------------------------------------------------------
> 
> ===== net/ipv4/netfilter/ip_nat_proto_tcp.c 1.10 vs edited =====
> --- 1.10/net/ipv4/netfilter/ip_nat_proto_tcp.c	2005-01-17 23:00:55 +01:00
> +++ edited/net/ipv4/netfilter/ip_nat_proto_tcp.c	2005-01-28 02:13:06 +01:00
> @@ -105,7 +105,7 @@
>  		return 0;
>  
>  	iph = (struct iphdr *)((*pskb)->data + iphdroff);
> -	hdr = (struct tcphdr *)((*pskb)->data + iph->ihl*4);
> +	hdr = (struct tcphdr *)((*pskb)->data + hdroff);
>  
>  	if (maniptype == IP_NAT_MANIP_SRC) {
>  		/* Get rid of src ip and src pt */


-- 
    -bill davidsen (davidsen@tmr.com)
"The secret to procrastination is to put things off until the
  last possible moment - but no longer"  -me
