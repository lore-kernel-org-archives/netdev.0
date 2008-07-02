From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Fwd: iproute2 / xtables / undefined symbol in m_ipt again
Date: Wed, 2 Jul 2008 12:10:12 -0700
Message-ID: <20080702121012.01678189@extreme>
References: <200807021308.20117.denys@visp.net.lb>
	<20080702111139.43ca320a@extreme>
	<200807022158.00343.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linuxfoundation.org, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58675 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755454AbYGBTKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 15:10:53 -0400
In-Reply-To: <200807022158.00343.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jul 2008 21:58:00 +0300
Denys Fedoryshchenko <denys@visp.net.lb> wrote:

> I did test on vanilla iptables and git iproute2.
> Only thing i change - corrected path to libraries in iproute2 sources.
> 
> How it can work correctly if iptables doesn't add param_act (which is inside xtables.o) to anything else than iptables/ip6tables/iptables-restore/iptables-multi binaries?
> It is physically impossible. Possibly your iproute2 using old iptables library, since in new one path to libraries is changed.
> 
> The new iptables will show:
> tablename: mangle hook: NF_IP_PRE_ROUTING
>         target: MARK xset 0xc8/0xffffffff  index 0
> 
> old:
> tablename: mangle hook: NF_IP_PRE_ROUTING
>         target: MARK set 0xcb  index 0
> 
> Command:
>     $TC filter add dev $2 parent ffff: protocol ip prio 10 u32 \
>       match u32 0 0 flowid 1:1 \
>       action ipt -j MARK --set-mark ${id} \
>       action mirred egress redirect dev ifb0
> 
> On Wednesday 02 July 2008, Stephen Hemminger wrote:
> > 
> > This needs more investigation.  I think it is more of problem with your iptables
> > library installation than iproute. It works fine for me build/run on Ubuntu Hardy.
> > 
> 
> 
> 

Ubuntu ships iptables 1.3.8 and Debian ships 1.4.0 in Lenny(testing), 1.3.6 in Sarge (stable[ancient])
Iptables needs to build/install working complete libraries. I'm not going to drag bits
and pieces back to iproute

If iptables 
