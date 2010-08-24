From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Tue, 24 Aug 2010 18:57:27 +0100
Message-ID: <1282672647.2302.15.camel@achroite.uk.solarflarecom.com>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
	 <20100823080543.319143e3@nehalam>
	 <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Marc Aurele La France <tsi@ualberta.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56008 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287Ab0HXR5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 13:57:32 -0400
In-Reply-To: <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-24 at 09:14 -0600, Marc Aurele La France wrote:
> On Mon, 23 Aug 2010, Stephen Hemminger wrote:
> > On Mon, 23 Aug 2010 08:44:37 -0600 (MDT)
> > Marc Aurele La France <tsi@ualberta.ca> wrote:
> >> In regrouping for my next tack at this, I noticed that all stack traces go
> >> through ip_append_data().  This would be ipv6_append_data() in the IPv6 case.
> >> A _very_ rough draft that would have ip_append_data() temporarily drop down
> >> to a smaller fake MTU follows ...
> 
> > Why doesn't NFS generate page size fragments?  Does Infiniband or your
> > device not support this?  Any thing that requires higher order allocation
> > is going to unstable under load.  Let's fix the cause not the apply bandaid
> > solution to the symptom.
> 
> From what I can tell, IP fragmentation is done centrally.
[...]

Stephen and I are not talking about IP fragmentation, but about the
ability to append 'fragments' to an skb rather than putting the entire
packet payload in a linear buffer.  See
<http://vger.kernel.org/~davem/skb_data.html>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

