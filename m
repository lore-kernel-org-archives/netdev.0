From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: ixgbe: SR-IOV, macvlan filter on VFs
Date: Thu, 14 Aug 2014 08:39:23 -0700
Message-ID: <53ECD82B.6080209@intel.com>
References: <53ECA5C9.2020904@univ-nantes.fr> <53ECCC01.4050400@gmail.com> <53ECD560.4000700@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yoann Juet <yoann.juet@univ-nantes.fr>
To: Yoann Juet <veilletechno-irts@univ-nantes.fr>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55009 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755134AbaHNPjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 11:39:36 -0400
In-Reply-To: <53ECD560.4000700@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 08:27 AM, Yoann Juet wrote:
>> hmm this should work I think.
>>
>> Did you set the VF mac address at some point with,
>>
>>      ip link set dev DEVICE vf NUM mac ADDR
>>
>> If not this how did you setup the virtual functions? Manually via
>> sriov_numvfs? Or via libvirt or other library.
> 
> I'm using libvirt with interface type 'network' or 'hostdev'. The mac
> address is optional within this configuration block. But, If omitted,
> it's automatically generated. Even if I could set the mac address via
> the 'ip link' command (not very practical with libvirt but possible),
> Keepalived still needs two mac addresses per VF. From the guest
> perspective:
>     - ethX: @mac1, @ip1
>     - macvlanX<->ethX: @mac2 (vmac), @ip2 (vip)
> 
> Correct me if I'm wrong, the command 'ip link set dev DEVICE vf NUM mac ADDR' can only set one mac per VF.
> 

Right this seems to be the case. My guess is libvirt uses the IFLA_VF_MAC
attribute to set the MAC from the host side. After this is done the PF
driver will deny any additional MAC requests from the VF which is where
you get that error message.

I need to check the libvirt theory but if that is the case I'm not sure
what the best fix off hand is. Maybe an option to libvirt not to set the
MAC via the PF. The other option would be to add another knob to allow the
setting of MAC addrs from the VF via 'ip link' similar to the TX spoofing
bit already in place. Both would presumably resolve your use case.

.John
