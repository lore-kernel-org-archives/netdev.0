From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] GRE: Use strlcat() for size checking
Date: Wed, 27 Mar 2013 16:10:15 -0400 (EDT)
Message-ID: <20130327.161015.2272912627472653661.davem@davemloft.net>
References: <1364410111-29418-1-git-send-email-geert@linux-m68k.org>
	<1364414776.2922.19.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, pshelar@nicira.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1364414776.2922.19.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Mar 2013 20:06:16 +0000

> On Wed, 2013-03-27 at 19:48 +0100, Geert Uytterhoeven wrote:
>> On m68k, gcc tries to be smart and turns
>> 
>>     strncat(name, "%d", 2);
>> 
>> into a call to strlen() and a 16-bit store, causing a link failure,
>> as arch/m68k/include/asm/string.h provides strlen() using a macro:
>> 
>>     ERROR: "strlen" [net/ipv4/ip_tunnel.ko] undefined!
> 
> Perhaps you should fix the string library for m68k, then!

Right, this symbol really must be provided.

You cannot merely provide inlines.

The off-by-one error is seperate, but that should be fixed
differently.
