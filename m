From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 12:52:41 +0200
Message-ID: <20060510125241.0bb0978b@griffin.suse.cz>
References: <200605061401.01795.IvDoorn@gmail.com>
	<200605100001.20180.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Olivier <o.cornu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:65452 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964913AbWEJKwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 06:52:44 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605100001.20180.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 May 2006 00:01:16 +0200, Ivo van Doorn wrote:
> Basicly the dscape stack is performing active scanning while the device is down,
> but during the active scan it is sending packets out, or at least attempting to do so.
> Besides the question if active scanning is preferred over passive scanning while interface is down,
> active scanning fails because the packets that should be send are being send through the regular
> xmit routines of the interface. (IFF_UP is not set for the interface)

When all interfaces are down, the card must be completely disabled. No
transmitting, no receiving. Currently, there is a (minor) bug in IBSS
code in d80211 stack which tries to perform scanning even when the
interface is down. It's not so important because generated probe
requests are never delivered to the driver if the card is disabled (i.e.
no interfaces are up).

> This means that besides enabling the radio which should be done in the driver, the stack should either bring
> up the interface when doing an active scan, or resort to passive scanning while interface is down.

The stack should not perform any scanning when the interface is not up.

 Jiri

-- 
Jiri Benc
SUSE Labs
