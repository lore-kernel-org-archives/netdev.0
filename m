From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 13:55:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0608291348520.25442@netcore.fi>
References: <20060829082435.GA2676@suse.de> <20060829.183426.52410264.yoshfuji@linux-ipv6.org>
 <20060829.025400.37356422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: yoshfuji@linux-ipv6.org, okir@suse.de, netdev@vger.kernel.org,
	jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:25500 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S932269AbWH2K4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 06:56:08 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060829.025400.37356422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006, David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Tue, 29 Aug 2006 18:34:26 +0900 (JST)
>
>> Further analysis is needed, but one idea is to skip
>> addrconf_dev_config() if !(dev->flags & IFF_MULTICAST).
>
> Yes, it is logical because without multicast IPV6 cannot
> work correctly.
>
> But from another perspective (I assume these bridged Xen devices use
> ARPHRD_ETHER, do they?) a device with ARPHRD_ETHER and cleared
> IFF_MULTICAST flag seems potentially problematic.  How many other
> things break over such a device?

It's not obvious that IFF_MULTICAST is good enough.  IMHO, you should 
be able to run addrconf on non-multicast interfaces as well (e.g., 
point-to-point interfaces, tunnels in particular).

It seems that current code already excludes IFF_NOARP interfaces 
though.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
