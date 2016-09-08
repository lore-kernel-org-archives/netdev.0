From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: vlan aware bridge doesn't propagate mac changes to vlans on top
 of it
Date: Thu, 8 Sep 2016 11:03:24 +0900
Message-ID: <871326a1-4d31-8327-8120-f2188ecf2d34@lab.ntt.co.jp>
References: <d8cc158b-8b3b-17eb-91cc-7a46d7fc011e@ziu.info>
 <1fb1ce35-60e8-481c-9533-afe2e585f6ca@lab.ntt.co.jp>
 <af2e0cf8-c580-83b5-3b7d-3a23a1cba06a@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Michal Soltys <soltys@ziu.info>,
        Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:39883 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbcIHCDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 22:03:54 -0400
In-Reply-To: <af2e0cf8-c580-83b5-3b7d-3a23a1cba06a@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/09/08 3:22, Michal Soltys wrote:
...
> 4.7.2
> git describe on that commit suggests it's been available since 4.6.x
> 
> What I did in details:
> 
> ip li add name port1b type veth peer name port1e
> ip li add br0 type bridge
> ip li set dev br0 type bridge vlan_default_pvid 0
> ip li set dev br0 type bridge vlan_filtering 1
> bridge vlan add dev br0 vid 10 self
> bridge vlan add dev br0 vid 250 untagged pvid self
> ip li add link br0 name vlan10 type vlan id 10
> ip li set port1b master br0
> 
> At this point br0.vlan10 had outdated mac after br0 took port1b's one as
> its own.

If the mac address of lower device is changed while vlan device is down,
the address will be synchronized when vlan device becomes up.
Please try "ip li set vlan10 up".

-- 
Toshiaki Makita
