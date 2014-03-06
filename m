From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 1/2] 6lowpan: reassembly: fix return of init
 function
Date: Thu, 6 Mar 2014 06:44:39 +0100
Message-ID: <20140306054437.GA13676@omega>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
 <1394052211-6976-2-git-send-email-alex.aring@gmail.com>
 <53179F64.4060501@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:64066 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbaCFFoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 00:44:46 -0500
Received: by mail-ee0-f53.google.com with SMTP id e51so871641eek.40
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 21:44:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <53179F64.4060501@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Thu, Mar 06, 2014 at 01:04:20AM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 03/05/2014 11:43 PM, Alexander Aring wrote:
> 
> >This patch adds a missing return after fragmentation init. Otherwise we
> >register a sysctl interface and deregister it afterwards which makes no
> >sense.
> 
> >Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> >---
> >  net/ieee802154/reassembly.c | 2 ++
> >  1 file changed, 2 insertions(+)
> 
> >diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
> >index 4511fc2..59db7b5 100644
> >--- a/net/ieee802154/reassembly.c
> >+++ b/net/ieee802154/reassembly.c
> >@@ -550,6 +550,8 @@ int __init lowpan_net_frag_init(void)
> >  	lowpan_frags.frag_expire = lowpan_frag_expire;
> >  	lowpan_frags.secret_interval = 10 * 60 * HZ;
> >  	inet_frags_init(&lowpan_frags);
> >+
> >+	return 0;
> 
>    Perhaps 'goto out' for "consistency" with the code above? (I don't know
> why they used "goto out' in the first place.)
> 
ok, thanks, I will remove the "goto out" and will replace it with a
"return 0" if you are fine with that.

- Alex
