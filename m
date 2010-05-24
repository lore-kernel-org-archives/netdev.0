From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe and SRIOV failure in driver?
Date: Mon, 24 May 2010 11:57:28 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF3C70D10@rrsmsx501.amr.corp.intel.com>
References: <0199E0D51A61344794750DC57738F58E70B08A2A20@GVW1118EXC.americas.hpqcorp.net>
 <43F901BD926A4E43B106BF17856F0755A79C061C@orsmsx508.amr.corp.intel.com>
 <0199E0D51A61344794750DC57738F58E70B14DC9A7@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Fischer, Anna" <anna.fischer@hp.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40396 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757689Ab0EXR5b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 13:57:31 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E70B14DC9A7@GVW1118EXC.americas.hpqcorp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fischer, Anna wrote:
>> Subject: RE: ixgbe and SRIOV failure in driver?
>> 
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org
>>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Fischer, Anna
>>> Sent: Friday, May 21, 2010 9:33 AM 
>>> To: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
>>> Subject: ixgbe and SRIOV failure in driver?
>>> 
>>> I am running a system with 3 Intel NICs. Two of them are 82598
>>> devices, and one is a SRIOV capable 82599.
>>> 
>>> All devices use the ixgbe driver. What happens (I believe) now is
>>> that when the driver loads at first, it sees the 82598 first
>>> (because of its position in the PCI tree) and then it says "Device
>>> not IOV capable - switching off IOV." 
>>> 
>>> So then it switches into non-IOV mode, and I can never enable SRIOV
>>> on my 82599, because the driver does not enable it any more for
>>> further devices. 
>>> 
>>> So to get around this issue, I tried to use pciback.hide to hide the
>>> 82598 devices from the OS. That way I was hoping that the driver
>>> would switch on SRIOV on my 82599. However, then I got a kernel
>>> panic on boot (see below). 
>>> 
>>> I am running Xen 4 and the Dom0 kernel is a 2.6.31 kernel.
>> 
>> The ixgbe driver included with the 2.6.31 kernel does not support
>> SR-IOV. Where did you get the driver that does?  Please run ethtool
>> -i <ethx> and post the results.
> 
> I have installed the driver separately on my pv-ops kernel.
> 
> [root@211052610-f-cpu ~]# ethtool -i eth
> driver: ixgbe
> version: 2.0.75.7-NAPI
> firmware-version: 0.9-3
> bus-info: 0000:05:00.0
> 
> I have attached a log on when the drivers loads. There is a bit more
> debugging information enabled. You can see that the driver loads at
> first on devices 0000:02:00.0 and 0000:02:00.1 which are 82598
> devices and don't support SRIOV. So the driver switches off SRIOV.
> When it loads it on the 82599 which sits on 0000:05:00.0, it does not
> even have the SRIOV parameter enabled anymore, even though I load the
> driver with 'modprobe ixgbe max_vfs=4'.      

Load the driver by specifying max_vfs for each adapter. For example if your adapters enumerate 82598, 82598, 82599:

modprobe ixgbe max_vfs=0,0,4

Thanks,
Emil