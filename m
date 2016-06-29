From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [net] e1000e: keep VLAN interfaces functional after rxvlan off
Date: Wed, 29 Jun 2016 17:42:57 -0400
Message-ID: <577440E1.9070308@redhat.com>
References: <1467171691-54525-1-git-send-email-jeffrey.t.kirsher@intel.com> <20160629.074006.1279014794531759883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33281 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcF2VnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:43:01 -0400
Received: by mail-qk0-f174.google.com with SMTP id q79so112985130qke.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 14:43:00 -0700 (PDT)
In-Reply-To: <20160629.074006.1279014794531759883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> Date: Tue, 28 Jun 2016 20:41:31 -0700
>
>> From: Jarod Wilson<jarod@redhat.com>
>>
>> I've got a bug report about an e1000e interface, where a VLAN interface is
>> set up on top of it:
>>
>> $ ip link add link ens1f0 name ens1f0.99 type vlan id 99
>> $ ip link set ens1f0 up
>> $ ip link set ens1f0.99 up
>> $ ip addr add 192.168.99.92 dev ens1f0.99
>>
>> At this point, I can ping another host on vlan 99, ip 192.168.99.91.
>> However, if I do the following:
>>
>> $ ethtool -K ens1f0 rxvlan off
>>
>> Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
>> again. I'm not sure if this is actually intended behavior, or if there's a
>> lack of software VLAN stripping fallback, or what, but things continue to
>> work if I simply don't call e1000e_vlan_strip_disable() if there are
>> active VLANs (plagiarizing a function from the e1000 driver here) on the
>> interface.
>>
>> Also slipped a related-ish fix to the kerneldoc text for
>> e1000e_vlan_strip_disable here...
>>
>> Signed-off-by: Jarod Wilson<jarod@redhat.com>
>> Tested-by: Aaron Brown<aaron.f.brown@intel.com>
>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>
> Applied, thanks.

Hm.. There was actually a v2 patch that followed this one that fixed the 
problem slightly differently and slightly better, I think.

http://marc.info/?l=intel-wired-lan&m=146551652424417&w=2

-- 
Jarod Wilson
jarod@redhat.com
