From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Wed, 08 Aug 2012 00:09:59 +0200
Message-ID: <1344377399.28967.198.camel@edumazet-glaptop>
References: <1344355878.28967.113.camel@edumazet-glaptop>
	 <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120807.145533.2161378343227639185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:61425 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab2HGWKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 18:10:04 -0400
Received: by wgbdr13 with SMTP id dr13so90968wgb.1
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 15:10:02 -0700 (PDT)
In-Reply-To: <20120807.145533.2161378343227639185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 14:55 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 7 Aug 2012 21:15:27 +0100
> 
> > Some day the compiler may be smart enough to ignore the different
> > between explicit and implicit zero-initialisation, and put it back in
> > BSS.  Declaring this __cache_aligned_in_smp might be a better option.
> 
> I'm surprised it doesn't already do this.
> 
> It definitely puts scalar explicit zero initializers into the BSS.

Not a const :


# cat try.c
const int scalar_value = 0;
const int scalar_value_bss;
int scalar_value = 0;
int scalar_value_bss;
main(int argc, char *argv[])
{
return 0;
}
# gcc -o try try.c && nm -v try|grep scalar_value
00000000004005cc R cscalar_value
0000000000601028 B scalar_value
000000000060102c B scalar_value_bss
0000000000601030 B cscalar_value_bss


gcc 4.6.3
