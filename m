From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: bridge vlan_filtering don't work with tap devices (qemu guests)
Date: Tue, 24 Dec 2013 21:45:05 +0900
Message-ID: <1387889105.3575.3.camel@ubuntu-vm-makita>
References: <717e26b0-fda3-4c97-81a6-45e67462cb6b@mailpro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexandre DERUMIER <aderumier@odiso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:46551 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab3LXMpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 07:45:12 -0500
In-Reply-To: <717e26b0-fda3-4c97-81a6-45e67462cb6b@mailpro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-23 at 17:02 +0100, Alexandre DERUMIER wrote:
> Hello,
> 
> I'm trying to use vlan_filtering on bridge.
> 
> setup is : 2 qemu virtual machines (tap0 and tap1), plugged in a bridge br0.
>            virtual machines don't tag packets.
> 
> 
> qemuvm1 eth0 --tap0----->br0<-------tap1---qemuvm2 eth0.
> 
> 
> with vlan_filtering disable, both vms can ping together.
> 
> 
> If I enabled filtering
> 
> #echo 1 > /sys/class/net/br0/bridge/vlan_filtering
> 
> Both vms cannot ping together anymore.
> 
> So, I have tried to put vlan on tap interfaces with
> 
> #bridge vlan add dev tap0 vid 10
> #bridge vlan add dev tap1 vid 10

If you want to send untagged frames, please try to make configuration
like this:
# bridge vlan add dev tap0 vid 10 pvid untagged
# bridge vlan add dev tap1 vid 10 pvid untagged

Thanks,
Toshiaki Makita

> #bridge vlan show
> port	vlan ids
> br0	None
> tap0	10
> tap1    10
> 
> 
> 
> But, it doesn't work.
> 
> tcpdump on bridge (tcpdump -i br0 -e -n) or in destination qemu (tcpdump -i eth0 -e -n) , don't see any packet
> 
> any idea ? 
> 
> Regards,
> 
> Alexandre Derumier
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
