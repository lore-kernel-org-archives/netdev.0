From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: TCP connections stall when station re-associates.
Date: Wed, 12 Jan 2011 13:19:51 -0800
Message-ID: <4D2E1AF7.4000104@candelatech.com>
References: <4D2CFDB8.3010907@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D2CFDB8.3010907-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/11/2011 05:02 PM, Ben Greear wrote:
>
> We're seeing something funny while testing ath9k and ath5k with
> multiple VIFs. We are using send-to-self routing rules
> and have a TCP connection going between two station interfaces
> connected to the same AP. Kernel is ~2.6.37 (wireless-testing from
> a few days ago, plus some local patches). We tried commercial
> APs and ath9k/ath5k APs running 2.6.37 kernel and hostap with
> similar results.

When the stations re-connect, we re-run dhcp client, which involves
setting IP to zero and then re-acquiring the IP address.  We
then set up new routing rules, etc to have it back to the way
it was before the station lost contact with the AP.

The TCP/IP connections are specifically bound to local IP and port.

Maybe it is invalid to expect TCP connections to survive this
IP change?

I'll work on reproducing this DHCP behaviour on some regular
wired interfaces and see if I can reproduce in a simpler test
case.

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
