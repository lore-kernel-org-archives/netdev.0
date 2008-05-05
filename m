From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: Neptune regression...
Date: Mon, 05 May 2008 14:15:02 -0700
Message-ID: <481F78D6.20704@sun.com>
References: <20080503.235212.140840235.davem@davemloft.net>
 <481F69CA.4070704@sun.com> <20080505.140309.128520489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:34261 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762414AbYEEVQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 17:16:48 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m45LGlMi026559
	for <netdev@vger.kernel.org>; Mon, 5 May 2008 14:16:47 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K0E00F01WIR7Q00@fe-sfbay-10.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Mon,
 05 May 2008 14:16:47 -0700 (PDT)
In-reply-to: <20080505.140309.128520489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Matheos Worku <Matheos.Worku@Sun.COM>
> Date: Mon, 05 May 2008 13:10:50 -0700
>
>   
>> I think the clean way to handle this would be to use the "board" 
>> property which exists for all Neptune variants, both in OBP properties  
>> as well as PCI VPD. I will work on the fix based on that approach  and 
>> will generate a patch as soon possible.
>>     
>
> There is no "board" property on my maramba on-board neptune device
> nodes.  And the vpd.board_model[] string is the empty string.
>
> See the OF tree dump below from my system.
>
> I would really prefer if you actually tested your changes on the
> relevant hardware.
>
> Thanks.
>
>                 Node 0xf02d64cc
>                     .node:  f02d64cc
>                     local-mac-address:  00144fa7.bd36
>                     mac-addresses:  00144fa7.bd36
>                     phy-type: 'mif'
>                     assigned-addresses:  82040010.00000000.01000000.00000000.01000000.82040018.00000000.00200000.00000000.00008000.82040020.00000000.00208000.00000000.00008000.82040030.00000000.00300000.00000000.00100000
>                     reg:  00040000.00000000.00000000.00000000.00000000.03040010.00000000.00000000.00000000.01000000.03040018.00000000.00000000.00000000.00008000.03040020.00000000.00000000.00000000.00008000.02040030.00000000.00000000.00000000.00100000
>                     model: 'SUNW,pcie-neptune'
>   
Dave,

I actually meant the "model" property which exists on all variants.  For 
Maramba, it  is 'SUNW,pcie-neptune'.
The fix I have in mind  would modify the function niu_pci_vpd_get_nports 
to use the "model" property instead of "board_model". I will test and 
make sure the fix works on appropriate  SPARC and X86 hardware.

Regards
Matheos

>                     compatible:  70636965.78313038.652c6162.63642e31.3038652e.302e3100.70636965.78313038.652c6162.63642e31.3038652e.30007063.69657831.3038652c.61626364.2e310070.63696578.31303865.2c616263.64007063.69657863.6c617373.2c303230.30303000.70636965.78636c61.73732c30.32303000.70636931.3038652c.61626364.00
>                     address-bits:  00000030
>                     max-frame-size:  00002400
>                     network-interface-type: 'ethernet'
>                     device_type: 'network'
>                     name: 'network'
>                     interrupts:  00000001
>                     cache-line-size:  00000010
>                     class-code:  00020000
>                     subsystem-vendor-id:  0000108e
>                     revision-id:  00000001
>                     device-id:  0000abcd
>                     vendor-id:  0000108e
>
>                 Node 0xf02e88ac
>                     .node:  f02e88ac
>                     local-mac-address:  00144fa7.bd37
>                     mac-addresses:  00144fa7.bd37
>                     phy-type: 'mif'
>                     assigned-addresses:  82040110.00000000.02000000.00000000.01000000.82040118.00000000.00210000.00000000.00008000.82040120.00000000.00218000.00000000.00008000.82040130.00000000.00400000.00000000.00100000
>                     reg:  00040100.00000000.00000000.00000000.00000000.03040110.00000000.00000000.00000000.01000000.03040118.00000000.00000000.00000000.00008000.03040120.00000000.00000000.00000000.00008000.02040130.00000000.00000000.00000000.00100000
>                     model: 'SUNW,pcie-neptune'
>                     compatible:  70636965.78313038.652c6162.63642e31.3038652e.302e3100.70636965.78313038.652c6162.63642e31.3038652e.30007063.69657831.3038652c.61626364.2e310070.63696578.31303865.2c616263.64007063.69657863.6c617373.2c303230.30303000.70636965.78636c61.73732c30.32303000.70636931.3038652c.61626364.00
>                     address-bits:  00000030
>                     max-frame-size:  00002400
>                     network-interface-type: 'ethernet'
>                     device_type: 'network'
>                     name: 'network'
>                     interrupts:  00000002
>                     cache-line-size:  00000010
>                     class-code:  00020000
>                     subsystem-vendor-id:  0000108e
>                     revision-id:  00000001
>                     device-id:  0000abcd
>                     vendor-id:  0000108e
>
>                 Node 0xf02fac8c
>                     .node:  f02fac8c
>                     local-mac-address:  00144fa7.bd38
>                     mac-addresses:  00144fa7.bd38
>                     phy-type: 'mif'
>                     assigned-addresses:  82040210.00000000.03000000.00000000.01000000.82040218.00000000.00220000.00000000.00008000.82040220.00000000.00228000.00000000.00008000.82040230.00000000.00500000.00000000.00100000
>                     reg:  00040200.00000000.00000000.00000000.00000000.03040210.00000000.00000000.00000000.01000000.03040218.00000000.00000000.00000000.00008000.03040220.00000000.00000000.00000000.00008000.02040230.00000000.00000000.00000000.00100000
>                     model: 'SUNW,pcie-neptune'
>                     compatible:  70636965.78313038.652c6162.63642e31.3038652e.302e3100.70636965.78313038.652c6162.63642e31.3038652e.30007063.69657831.3038652c.61626364.2e310070.63696578.31303865.2c616263.64007063.69657863.6c617373.2c303230.30303000.70636965.78636c61.73732c30.32303000.70636931.3038652c.61626364.00
>                     address-bits:  00000030
>                     max-frame-size:  00002400
>                     network-interface-type: 'ethernet'
>                     device_type: 'network'
>                     name: 'network'
>                     interrupts:  00000003
>                     cache-line-size:  00000010
>                     class-code:  00020000
>                     subsystem-vendor-id:  0000108e
>                     revision-id:  00000001
>                     device-id:  0000abcd
>                     vendor-id:  0000108e
>
>                 Node 0xf030d06c
>                     .node:  f030d06c
>                     local-mac-address:  00144fa7.bd39
>                     mac-addresses:  00144fa7.bd39
>                     phy-type: 'mif'
>                     assigned-addresses:  82040310.00000000.04000000.00000000.01000000.82040318.00000000.00230000.00000000.00008000.82040320.00000000.00238000.00000000.00008000.82040330.00000000.00600000.00000000.00100000
>                     reg:  00040300.00000000.00000000.00000000.00000000.03040310.00000000.00000000.00000000.01000000.03040318.00000000.00000000.00000000.00008000.03040320.00000000.00000000.00000000.00008000.02040330.00000000.00000000.00000000.00100000
>                     model: 'SUNW,pcie-neptune'
>                     compatible:  70636965.78313038.652c6162.63642e31.3038652e.302e3100.70636965.78313038.652c6162.63642e31.3038652e.30007063.69657831.3038652c.61626364.2e310070.63696578.31303865.2c616263.64007063.69657863.6c617373.2c303230.30303000.70636965.78636c61.73732c30.32303000.70636931.3038652c.61626364.00
>                     address-bits:  00000030
>                     max-frame-size:  00002400
>                     network-interface-type: 'ethernet'
>                     device_type: 'network'
>                     name: 'network'
>                     interrupts:  00000004
>                     cache-line-size:  00000010
>                     class-code:  00020000
>                     subsystem-vendor-id:  0000108e
>                     revision-id:  00000001
>                     device-id:  0000abcd
>                     vendor-id:  0000108e
>
>
>   

