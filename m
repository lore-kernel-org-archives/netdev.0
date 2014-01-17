From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 1/6] net: rfkill: gpio: fix gpio name buffer size
 off by 1
Date: Fri, 17 Jan 2014 09:46:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45EA9D@AcuExch.aculab.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
 <1389941251-32692-2-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-sunxi@googlegroups.com" <linux-sunxi@googlegroups.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: 'Chen-Yu Tsai' <wens@csie.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39297 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752118AbaAQJsX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 04:48:23 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03716-01 for <netdev@vger.kernel.org>;
 Fri, 17 Jan 2014 09:48:20 +0000 (GMT)
In-Reply-To: <1389941251-32692-2-git-send-email-wens@csie.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen-Yu Tsai
> snprintf should be passed the complete size of the buffer, including
> the space for '\0'. The previous code resulted in the *_reset and
> *_shutdown strings being truncated.
...
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
...
> -	snprintf(rfkill->reset_name, len + 6 , "%s_reset", rfkill->name);
> -	snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", rfkill->name);
> +	snprintf(rfkill->reset_name, len + 7 , "%s_reset", rfkill->name);
> +	snprintf(rfkill->shutdown_name, len + 10, "%s_shutdown", rfkill->name);

I can't find the context for the above, but they look very dubious.
I'd expect: snprintf(foo, sizeof foo, ...).
If you are trying to truncate rfkill->name you need to use %.*s.

	David
