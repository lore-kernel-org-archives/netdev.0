From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: call notifiers for mtu change even if
 iface is not up
Date: Fri, 7 Dec 2012 13:29:20 +0100
Message-ID: <20121207122920.GB1631@minipsycho.zyxel.com>
References: <1354533392-9308-1-git-send-email-jiri@resnulli.us>
 <20121203141823.GA21816@hmsreliant.think-freely.org>
 <20121203142229.GA3054@minipsycho.orion>
 <20121203152250.GB21816@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, psimerda@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:50222 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933740Ab2LGM3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 07:29:24 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so160871eaa.19
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 04:29:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121203152250.GB21816@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 03, 2012 at 04:22:50PM CET, nhorman@tuxdriver.com wrote:
>On Mon, Dec 03, 2012 at 03:22:29PM +0100, Jiri Pirko wrote:
>> Mon, Dec 03, 2012 at 03:18:23PM CET, nhorman@tuxdriver.com wrote:
>> >On Mon, Dec 03, 2012 at 12:16:32PM +0100, Jiri Pirko wrote:
>> >> Do the same thing as in set mac. Call notifiers every time.
>> >> 
>> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >> ---
>> >>  net/core/dev.c | 2 +-
>> >>  1 file changed, 1 insertion(+), 1 deletion(-)
>> >> 
>> >> diff --git a/net/core/dev.c b/net/core/dev.c
>> >> index 2f94df2..0685a72 100644
>> >> --- a/net/core/dev.c
>> >> +++ b/net/core/dev.c
>> >> @@ -4971,7 +4971,7 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
>> >>  	else
>> >>  		dev->mtu = new_mtu;
>> >>  
>> >> -	if (!err && dev->flags & IFF_UP)
>> >> +	if (!err)
>> >>  		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
>> >>  	return err;
>> >>  }
>> >
>> >I'm not opposed to this change, but is there something that it expressly fixes?
>> 
>> This is about a consistency. To have the same behaviour as set_mac
>> for example.
>> 
>> >While it doesn't hurt to send around mtu change events, one would presume that
>> >listeners would pick up mtu changes when the NETDEV_UP event went' around.
>> >
>> >Neil
>> >
>I figured, I just wanted to be sure that there wasn't a bug fix that needed
>documenting in the changelog, or that listeners for this event didn't expect the
>interface to already be up.  It looks pretty clean, with the exception of the
>TIPC protocol.  It appears that it might require enable_bearer to be called
>prior to any netdevice CHANGEMTU events, so that the eth_bearers array gets
>filled out, and it looks like that has to get triggered either by user space, or
>the receipt of a message over the network.  Let me know what you think

I'm looking at the code. What is the difference between CHANGEMTU and
CHANGEADDR here? It looks to me that it should work for both in the same
way.


>
>Neil
>
>> >--
>> >To unsubscribe from this list: send the line "unsubscribe netdev" in
>> >the body of a message to majordomo@vger.kernel.org
>> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
