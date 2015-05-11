From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux
 v4.0-9362-g1fc149933fd4
Date: Mon, 11 May 2015 07:53:06 -0700
Message-ID: <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	 <20150504133943.GA17043@x131e>
	 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	 <20150504132714.55dca5b0@urahara>
	 <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
	 <20150511131516.GC10375@x131e>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dominick Grift <dac.override@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33124 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbbEKOxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 10:53:08 -0400
Received: by igbpi8 with SMTP id pi8so73537995igb.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 07:53:08 -0700 (PDT)
In-Reply-To: <20150511131516.GC10375@x131e>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-11 at 15:15 +0200, Dominick Grift wrote:
> On Mon, May 04, 2015 at 02:35:27PM -0700, Cong Wang wrote:
> 
> <snip>
> 
> > It _looks like_ we only retrieve vlan info to fill netlink
> > messages in timer context, so it doesn't seem we need to
> > hold br->lock here.
> > 
> > But I never look into br vlan code of course.
> 
> This is just a friendly reminder that this issue still exits in: 4.1.0-0.rc2.git3.1
> 
> Ignore me if you are aware of the above
> 

Hi Dominick

Have you tried this patch I sent last monday ?

I will submit formally when I get a test result.

Thanks

diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 4fcaa67750fda845ad0a180332c4cd96a9524086..7caf7fae2d5b8aa369b924e1c87a47c343fb8954 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -97,7 +97,9 @@ static void br_forward_delay_timer_expired(unsigned long arg)
 		netif_carrier_on(br->dev);
 	}
 	br_log_state(p);
+	rcu_read_lock();
 	br_ifinfo_notify(RTM_NEWLINK, p);
+	rcu_read_unlock();
 	spin_unlock(&br->lock);
 }
 
