From: Michal Soltys <soltys@ziu.info>
Subject: Re: vlan aware bridge doesn't propagate mac changes to vlans on top
 of it
Date: Thu, 8 Sep 2016 23:16:34 +0200
Message-ID: <e243444f-f048-116c-8fea-dbb509951b8a@ziu.info>
References: <d8cc158b-8b3b-17eb-91cc-7a46d7fc011e@ziu.info>
 <1fb1ce35-60e8-481c-9533-afe2e585f6ca@lab.ntt.co.jp>
 <af2e0cf8-c580-83b5-3b7d-3a23a1cba06a@ziu.info>
 <871326a1-4d31-8327-8120-f2188ecf2d34@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:42107 "EHLO drutsystem.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932460AbcIHVQk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 17:16:40 -0400
In-Reply-To: <871326a1-4d31-8327-8120-f2188ecf2d34@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-09-08 04:03, Toshiaki Makita wrote:
> On 2016/09/08 3:22, Michal Soltys wrote:
> ...
>> 4.7.2
>> git describe on that commit suggests it's been available since 4.6.x
>> 
>> What I did in details:
>> 
>> ip li add name port1b type veth peer name port1e
>> ip li add br0 type bridge
>> ip li set dev br0 type bridge vlan_default_pvid 0
>> ip li set dev br0 type bridge vlan_filtering 1
>> bridge vlan add dev br0 vid 10 self
>> bridge vlan add dev br0 vid 250 untagged pvid self
>> ip li add link br0 name vlan10 type vlan id 10
>> ip li set port1b master br0
>> 
>> At this point br0.vlan10 had outdated mac after br0 took port1b's one as
>> its own.
> 
> If the mac address of lower device is changed while vlan device is down,
> the address will be synchronized when vlan device becomes up.
> Please try "ip li set vlan10 up".
> 

Gah, yea upping interface updates it correctly. Originally I found this
issue on older kernel, so I quickly verified the behaviour on the
current one - but didn't do ip up.

Sorry for the noise.
