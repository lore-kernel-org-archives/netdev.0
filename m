From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [3/5] netdev: HH_DATA_OFF bugfix
Date: Fri, 27 May 2005 23:15:18 -0400
Message-ID: <4297E246.1070606@pobox.com>
References: <20050524150711.01632672@griffin.suse.cz> <20050524151204.554f73cb@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050524151204.554f73cb@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> When the hardware header size is a multiple of HH_DATA_MOD, HH_DATA_OFF()
> incorrectly returns HH_DATA_MOD (instead of 0).
> 
> Signed-off-by: Jiri Benc <jbenc@suse.cz>
> 
> --- linux/include/linux/netdevice.h
> +++ work/include/linux/netdevice.h
> @@ -204,7 +209,7 @@
>  	/* cached hardware header; allow for machine alignment needs.        */
>  #define HH_DATA_MOD	16
>  #define HH_DATA_OFF(__len) \
> -	(HH_DATA_MOD - ((__len) & (HH_DATA_MOD - 1)))
> +	(HH_DATA_MOD - (((__len - 1) & (HH_DATA_MOD - 1)) + 1))
>  #define HH_DATA_ALIGN(__len) \
>  	(((__len)+(HH_DATA_MOD-1))&~(HH_DATA_MOD - 1))
>  	unsigned long	hh_data[HH_DATA_ALIGN(LL_MAX_HEADER) / sizeof(long)];


You'll want to run this one by DaveM.  He would be the appropriate one 
to merge this, since it affects all ethernet devices (net/ethernet/eth.c 
uses HH_DATA_OFF macro).

I'm going over the rest of the ieee80211/ipw patches...

	Jeff
