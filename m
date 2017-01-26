From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: IPv6-UDP 0x0000 checksum
Date: Thu, 26 Jan 2017 16:36:25 +0100
Message-ID: <1485444985.14760.14.camel@sipsolutions.net>
References: <1485437276.14760.3.camel@sipsolutions.net>
         <1485438299.5145.117.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_144502_343976_16232A6D) <1485438546.14760.7.camel@sipsolutions.net>
         <1485441942.5145.131.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_154545_190303_B1FB80BF) <1485442164.14760.11.camel@sipsolutions.net>
         <1485444276.5145.133.camel@edumazet-glaptop3.roam.corp.google.com>
         <1485444476.5145.136.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_162759_798052_1A660877)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485444476.5145.136.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org> (sfid-20170126_162759_798052_1A660877)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-26 at 07:27 -0800, Eric Dumazet wrote:
> 
>                 if (!uh->check && !udp_sk(sk)->no_check6_rx) {
>                         udp6_csum_zero_error(skb);
>                         goto csum_error;
>                 }



Yeah, I'd found no_check6_rx already, was still trying to figure out this one :)

Looks like we actually check uh->check regardless of anything the
driver said (CHECKSUM_UNNECESSARY, or whatever), so we should be fine
even with the hardware tagging it as good in this case.

johannes
