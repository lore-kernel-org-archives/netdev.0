From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] bonding: warn user when 802.3ad speed is unknown
Date: Fri, 9 Jun 2017 16:39:06 +0200
Message-ID: <fcca67e0-a170-6dd7-dcbb-7a0ecc0453d5@6wind.com>
References: <20170608164811.GB20216@lunn.ch>
 <1497015283-1729-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170609142359.GD20756@lunn.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:35024 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdFIOjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 10:39:10 -0400
Received: by mail-wr0-f180.google.com with SMTP id q97so35618192wrb.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 07:39:09 -0700 (PDT)
In-Reply-To: <20170609142359.GD20756@lunn.ch>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/06/2017 à 16:23, Andrew Lunn a écrit :
> On Fri, Jun 09, 2017 at 03:34:43PM +0200, Nicolas Dichtel wrote:
>> Make it explicit in the log.
>>
>> Suggested-by: Andrew Lunn <andrew@lunn.ch>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Hi Nicolas
Hi Andrew,

> 
> How often is this called? It seems like it is used by
Good question! ;-)

> ad_port_selection_logic, which has the comment:
> 
> 	is called in the inititalization (after all the handshkes),
> 	and after every lacpdu receive (if selected is off)
> 
> I just wonder if this should be rate limited?
So using net_warn_ratelimited()?

Displaying this message continuously in the log, even at a low rate, seems not
the best things to do. The first time seems enough, but it would require more
code for that. Is it not over-engineering?
The ideal solution would be a BUILD_BUG_ON(), but I don't see how to make that.

Regards,
Nicolas
