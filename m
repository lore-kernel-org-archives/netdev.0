From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Fwd: iproute2 / xtables / undefined symbol in m_ipt again
Date: Wed, 2 Jul 2008 21:58:00 +0300
Message-ID: <200807022158.00343.denys@visp.net.lb>
References: <200807021308.20117.denys@visp.net.lb> <20080702111139.43ca320a@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linuxfoundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:54294 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbYGBS6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 14:58:00 -0400
In-Reply-To: <20080702111139.43ca320a@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did test on vanilla iptables and git iproute2.
Only thing i change - corrected path to libraries in iproute2 sources.

How it can work correctly if iptables doesn't add param_act (which is inside xtables.o) to anything else than iptables/ip6tables/iptables-restore/iptables-multi binaries?
It is physically impossible. Possibly your iproute2 using old iptables library, since in new one path to libraries is changed.

The new iptables will show:
tablename: mangle hook: NF_IP_PRE_ROUTING
        target: MARK xset 0xc8/0xffffffff  index 0

old:
tablename: mangle hook: NF_IP_PRE_ROUTING
        target: MARK set 0xcb  index 0

Command:
    $TC filter add dev $2 parent ffff: protocol ip prio 10 u32 \
      match u32 0 0 flowid 1:1 \
      action ipt -j MARK --set-mark ${id} \
      action mirred egress redirect dev ifb0

On Wednesday 02 July 2008, Stephen Hemminger wrote:
> 
> This needs more investigation.  I think it is more of problem with your iptables
> library installation than iproute. It works fine for me build/run on Ubuntu Hardy.
> 



-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
