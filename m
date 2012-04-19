From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Thu, 19 Apr 2012 14:58:48 +0200
Message-ID: <4F900C08.5000906@st.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>  <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com> <1334269598.2497.50.camel@bwh-desktop.uk.solarflarecom.com> <4F8BB103.7020107@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com,
	davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:43351 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753449Ab2DSNAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 09:00:52 -0400
In-Reply-To: <4F8BB103.7020107@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

On 4/16/2012 7:41 AM, Giuseppe CAVALLARO wrote:
[snip]
>> What I meant is that userland should be able to find out (a), and,
>> *separately*, either (b) or (c).  That is, there must be at least 2
>> separate flags for this.  In fact, I explicitly requested you define
>> supported/advertising/lp_advertising bitmasks for EEE link modes just
>> like we have for autonegotiation.  But you've made no substantive
>> changes in response to my review, aside from dropping the added field in
>> ethtool_cmd.
> 
> Sorry Ben but I believed that (c) was enough.
> 
>> What you're submitting just isn't good enough for a generic interface,
>> as the ethtool API is supposed to be.  It's not even a good interface to
>> your driver.
> 
> yes! I'll rework this and provide new patches asap.

sorry if I disturb you but I want to be sure to avoid to forget
something else in the next EEE patches (avoiding to continuously disturb
you).

I'm changing the code for getting/setting the EEE capability and trying
to follow your suggestions.

The "get" will show the following things; this is a bit different of the
points "a" "b" and "c" we had discussed. Maybe, this could also be a
more complete (*) .
The ethtool (see output below as example) could report the phy
(supported/advertised/lp_advertised) and mac eee capabilities separately.

The "set" will be useful for some eth devices (like the stmmac) that can
stop/enable internally the eee capability (at mac level).

What do you think?

Regards
Peppe

----

# ./ethtool  eth0
Settings for eth0:

[snip]

	Current message level: 0x0000003f (63)
			       drv probe link timer ifdown ifup
	Link detected: yes
	Energy-Efficient Ethernet:           -------------------------
		MAC supports: yes            |-> related to MAC side  |
		phy supports modes: ...      |-> from MMD 3.20        |
		phy advertising modes: ...   |-> from MMD 7.60        |
		LP advertising modes: ...    |-> from MMD 7.61        |
					     --------------------------
                                                    (*)
PS. The "..." above means that we can actually dump: 100BASE-TX EEE etc
for each advertising modes and also for phy support (reg 3.20).

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
