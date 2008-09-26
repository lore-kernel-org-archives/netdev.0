From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Invalid truesize messages since 2.6.25
Date: Fri, 26 Sep 2008 22:53:35 +0100
Message-ID: <1222466015.8641.113.camel@achroite>
References: <3C59DB883F7B0B4D8096010D45ACCD13C73CAE@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:40569 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752335AbYIZVxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 17:53:38 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13C73CAE@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-09-26 at 19:53 +0200, Beschorner Daniel wrote:
> I did some more investigations and can reproduce it now in a simple way:
> 
> I take my tg3 device into promiscuous mode and capture ESP packets:
> Just "tcpdump -i eth1 esp" and ping 4 times through the IPSEC tunnel to
> generate ESP traffic, after that dmesg shows
> 
> device eth1 entered promiscuous mode
> SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
> SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
> device eth1 left promiscuous mode
> 
> Daniel
> 
> ----------
> Since 2.6.25 we rarely see these messages:
> 
> SKB BUG: Invalid truesize (408) len=198, sizeof(sk_buff)=216
> 
> Yesterday I saw it the first time after a runtime of one week with
> 2.6.26.
> The box is web server / IPSEC gateway.
> Obviously nothing seems to be affected by the message but <= 2.6.24 no
> messages appeared.

Commit 3ab224be6d69de912ee21302745ea45a99274dbc, applied between 2.6.24
and 2.6.25, appears to ensure that truesize is checked for all skbs
where previously it was only done for some.  The bug probably already
existed in the ipsec code, which never updates truesize.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

