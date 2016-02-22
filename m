From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH][net-next] bridge: increase mtu to 9000
Date: Mon, 22 Feb 2016 09:58:08 -0800
Message-ID: <20160222095808.72edd4f9@xeon-e3>
References: <1456133351-10292-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33733 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbcBVR56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 12:57:58 -0500
Received: by mail-pf0-f174.google.com with SMTP id q63so96231930pfb.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 09:57:58 -0800 (PST)
In-Reply-To: <1456133351-10292-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Feb 2016 17:29:11 +0800
roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> A linux bridge always adopts the smallest MTU of the enslaved devices.
> When no device are enslaved, it defaults to a MTU of 1500 and refuses to
> use a larger one. This is problematic when using bridges enslaving only
> virtual NICs (vnetX) like it's common with KVM guests.
> 
> Steps to reproduce the problem
> 
> 1) sudo ip link add br-test0 type bridge # create an empty bridge
> 2) sudo ip link set br-test0 mtu 9000 # attempt to set MTU > 1500
> 3) ip link show dev br-test0 # confirm MTU
> 
> Here, 2) returns "RTNETLINK answers: Invalid argument". One (cumbersome)
> way around this is:
> 
> 4) sudo modprobe dummy
> 5) sudo ip link set dummy0 mtu 9000 master br-test0
> 
> Then the bridge's MTU can be changed from anywhere to 9000.
> 
> This is especially annoying for the virtualization case because the
> KVM's tap driver will by default adopt the bridge's MTU on startup
> making it impossible (without the workaround) to use a large MTU on the
> guest VMs.
> 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1399064
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Your change works, but I agree with Hannes. Just allow up to 64 * 1024 like
loopback does.  And no need for a #define for that it is only in one place.
