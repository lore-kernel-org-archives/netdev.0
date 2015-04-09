From: Michael Cronenworth <mike@cchtml.com>
Subject: Re: [PATCH] e1000e: Cleanup handling of VLAN_HLEN as a part of max
 frame size
Date: Wed, 08 Apr 2015 23:48:51 -0500
Message-ID: <552604B3.9070204@cchtml.com>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org> <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, htodd@twofifty.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta11.charter.net ([216.33.127.80]:43432 "EHLO
	mta11.charter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbbDIEs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 00:48:58 -0400
Received: from imp09 ([10.20.200.9]) by mta11.charter.net
          (InterMail vM.8.01.05.09 201-2260-151-124-20120717) with ESMTP
          id <20150409044857.ZGH5815.mta11.charter.net@imp09>
          for <netdev@vger.kernel.org>; Thu, 9 Apr 2015 00:48:57 -0400
Received: from impout002 ([68.114.189.17])
          by mtaout001.msg.strl.va.charter.net
          (InterMail vM.9.00.015.01 201-2473-143-101) with ESMTP
          id <20150409044857.WKCM21632.mtaout001.msg.strl.va.charter.net@impout002>
          for <netdev@vger.kernel.org>; Wed, 8 Apr 2015 23:48:57 -0500
In-Reply-To: <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 04:02 PM, Alexander Duyck wrote:
> When the VLAN_HLEN was added to the calculation for the maximum frame size
> there seems to have been a number of issues added to the driver.
>
> The first issue is that in some cases the maximum frame size for a device
> never really reached the actual maximum frame size as the VLAN header
> length was not included the calculation for that value.  As a result some
> parts only supported a maximum frame size of either 1496 in the case of
> parts that didn't support jumbo frames, and 8996 in the case of the parts
> that do.
>
> The second issue is the fact that there were several checks that weren't
> updated so as a result setting an MTU of 1500 was treated as enabling jumbo
> frames as the calculated value was 1522 instead of 1518.  I have addressed
> those by replacing ETH_FRAME_LEN with VLAN_ETH_FRAME_LEN where appropriate.
>
> The final issue was the fact that lowering the MTU below 1500 would cause
> the driver to allocate 2K buffers for the rings.  This is an old issue that
> was fixed several years ago in igb/ixgbe and I am addressing now by just
> replacing == with a <= so that we always just round up to 1522 for anything
> that isn't a jumbo frame.

Alex,

Thanks taking the time to work on a patch.

I have tested this patch in 4.0 on i218-v hardware and it is working. I see 9000 in 
tcpdump (tso/gso off) and my switch blocks packets if I set the max frame size to 
9017 down from 9018.

I also played with a VLAN real quick, and did not encounter any problems, but I 
don't normally use VLANs so it may need further testing.

Thanks,
Michael
