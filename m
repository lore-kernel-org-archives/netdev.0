From: Steven Barth <steven@midlink.org>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Mon, 22 Jun 2015 07:58:48 +0200
Message-ID: <5587A418.4000308@midlink.org>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi> <5586F1F8.1070800@universe-factory.net> <0D0CB420-018B-465C-B27B-72016F41C268@iki.fi> <55873C46.4090804@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matthias Schiffer <mschiffer@universe-factory.net>,
	Markus Stenberg <markus.stenberg@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.core-networks.de ([82.96.72.7]:53680 "EHLO
	mail.core-networks.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbbFVG30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 02:29:26 -0400
In-Reply-To: <55873C46.4090804@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.06.2015 00:35, Matthias Schiffer wrote:
> Could you explain in detail what you mean with "If you want specific SA,
> add same route with higher metric and/or (more) specific src match."?
> Routes aren't bound to specific addresses except via the "src" attribute
> (which is called prefsrc in the kernel), which is exactly what it not
> working. I can't control the chosen source address at all when
> source-specific routes are involved.
Except that prefsrc and src are two different beasts and usually ip route from transates to
RTA_SRC instead of RTA_PREFSOURCE when used with a prefix length.

Try adding two routes to the same destination with the same metric but different source values with PREFSRC (e.g. IPv4) and then
try doing the same with SRC (e.g. IPv6). The former will fail but the latter will succeed.


https://tools.ietf.org/html/draft-troan-homenet-sadr-01
was the original draft for source-address dependent routing IIRC so might be a good read.


> 
> Even though the source-specific route has a higher metric than the
> generic one, the source-specific one shadows the generic route.

(was a bit ago since I read into this so please correct me if I am wrong)
IIRC this is intentional since longest-prefix-match beats metric here
and the source-address match counts to being more-specific here. See also above difference between PREFSRC and SRC.



Cheers,

Steven
