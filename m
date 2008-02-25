From: Joe Perches <joe@perches.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 08:53:49 -0800
Message-ID: <1203958429.19319.273.camel@localhost>
References: <1203589042.17534.145.camel@johannes.berg>
	 <1203616486.7181.269.camel@localhost> <47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
	 <1203933228.13162.58.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2659 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756192AbYBYQyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 11:54:51 -0500
In-Reply-To: <1203933228.13162.58.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-25 at 10:53 +0100, Johannes Berg wrote:
> Maybe we should just add a new printf modifier like %M for MAC
> addresses? Then we could use sprintf, snprintf, printk and whatever we
> please without any of the macro stuff...

Could gcc validate the printf %M arguments?

Another possibility without changing printf argument validation
is to use a MAC_FMT macro in place of "%s"

#ifdef CONFIG_INLINE_MAC

#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
#define DECLARE_MAC_BUF(var)
#define print_mac(buf, addr) (addr)[0], (addr)[1], (addr)[2], (addr)[3], (addr)[4], (addr)[5]

#else

#define MAC_FMT "%s"
#define DECLARE_MAC_BUF(var) char var[18];
extern char *print_mac(char *buf, const unsigned char *addr);

#endif

use:

DECLARE_MAC_BUF(mac);
printk(KERN_INFO "Mac address is: " MAC_FMT "\n", print_mac(mac, addr));

