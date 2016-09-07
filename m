From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: vlan aware bridge doesn't propagate mac changes to vlans on top
 of it
Date: Wed, 7 Sep 2016 09:44:54 +0900
Message-ID: <1fb1ce35-60e8-481c-9533-afe2e585f6ca@lab.ntt.co.jp>
References: <d8cc158b-8b3b-17eb-91cc-7a46d7fc011e@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Michal Soltys <soltys@ziu.info>,
        Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:54503 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbcIGApR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 20:45:17 -0400
In-Reply-To: <d8cc158b-8b3b-17eb-91cc-7a46d7fc011e@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/09/07 6:59, Michal Soltys wrote:
> Consider following scenario:
> 
> - create vlan aware bridge (say br0)
> - setup br0's vlans, e.g.
> 
> bridge vlan add dev br0 vid 10 self
> 
> This will add necessary fdb entries directing appropriate traffic to the
> bridge itself.
> 
> - create appropriate vlan interfaces on top of it, for example:
> 
> ip li add link br0 name br0.10 type vlan id 10
> ip add add 10.0.0.1/8 dev br0.10 ....
> 
> This will add vlan devices on top of br0 and *inherit br0's mac address*.
> 
> - now after all of the above is done
> 
> ip li set eth0 master br0
> 
> This will attach interface eth0 to the bridge. With this being the first
> interface attached, br0 will take it's mac address as its own. Any
> further changes to br0's ports may cause the same, with the lowest mac
> address of some port becoming br0's mac.
> 
> This will update fdb entries as well, but all vlan interfaces on top of
> br0 (e.g. br0.10) will be using old mac address from the time when vlan
> was created.
> 
> The side effect of it is that any traffic addressed to such interface
> will be flooded to all ports (and br0 itself).
> 
> The only workaround I found is to either manually update mac addresses
> with 'ip' or recreate vlans (bridge fdb refused to update relevant entries).
> 
> But if br0's mac changes due to some port changes - shouldn't it be
> somehow propagated automatically to vlans created on top of it ?

This should have been addressed at least in kernel 4.7...
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=308453aa9156a3b8ee382c0949befb507a32b0c1

Which kernel version do you use?

-- 
Toshiaki Makita
