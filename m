From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Hardware capabilities and bonding offload
Date: Mon, 16 Nov 2015 16:30:32 +0100
Message-ID: <20151116153032.GC2217@nanopsycho.orion>
References: <77EF4405DD4BB54AACCE7DB593DF6A9AA0D643@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38820 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbbKPPaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 10:30:35 -0500
Received: by wmec201 with SMTP id c201so125293485wme.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 07:30:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9AA0D643@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 16, 2015 at 10:29:12AM CET, pjonnala@broadcom.com wrote:
>Hello,
>
>I am looking to offload bond interfaces to hardware for forwarding.  Linux allows for configuring 
>a variety of parameters on bonds or slave interfaces.  Not all configurations can be offloaded to 
>hardware.  For example, certain hardware cannot support bonds with mode of adaptive load balancing.
>
>When such a configuration is provided by user, we have two options at hand (for platforms supporting
>hardware offloads):
>
>1. Reject the configuration.  
>
>2. Handle the bond interface in software.  In a scenario where this bond interface is part
>of a bridge interface, for simplicity purpose, all other interfaces in the bridge need to be 
>handled in software - which results in a very low packet processing performance.

Although it might sound intriguing to fallback to sw here, it makes no
sense and user certainly does not want that. For example in case of our
HW, we have 100gbit forwarding which would be degraded to ~1gbit (for one
port pair). Another thing is that for some HW this mignt not be even
possible. In our case it would be very complicated.

I believe that the correct approach is to let driver decide if the
configuration is acceptable or not and reject it in case it is not.


>
>I'm writing to gather feedback on the approach to take, including any other suggestions.
>We have discussed this briefly in our weekly netdev meeting, and I received votes for
>option #1.
>
>Thanks
>Prem
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
