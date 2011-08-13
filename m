From: Ed Swierk <eswierk@bigswitch.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Fri, 12 Aug 2011 22:43:33 -0700
Message-ID: <CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
 <CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com> <20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:45959 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab1HMFoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 01:44:14 -0400
Received: by vxi9 with SMTP id 9so2882637vxi.19
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2011 22:44:13 -0700 (PDT)
In-Reply-To: <20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2011 at 3:45 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> If you turn off STP that is what it does right now. It forwards STP
> and 802.1X frames. The patch was only related to turning on STP
> and still expecting 802.1X frames to be forwarded (in violation of
> the spec).

As far as I can tell, the only case currently where the bridge
forwards a packet destined for a link-local multicast address is

  if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)

dest[5] != 0 for an LLDP packet, whose destination address is
01-80-C2-00-00-0E per IEEE 802.1AB-2005.

--Ed
