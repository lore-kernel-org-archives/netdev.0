From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [PATCH] e1000e: Cleanup handling of VLAN_HLEN as a part of max
 frame size
Date: Wed, 8 Apr 2015 17:26:05 -0700 (PDT)
Message-ID: <alpine.NEB.2.11.1504081714400.3388@chris.i8u.org>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org> <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22> <alpine.NEB.2.11.1504081413510.3388@chris.i8u.org> <5525B2AE.80301@gmail.com> <alpine.NEB.2.11.1504081602260.3388@chris.i8u.org>
 <5525B62A.1050601@gmail.com> <alpine.NEB.2.11.1504081705350.3388@chris.i8u.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, mike@cchtml.com, david.m.ertman@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-148-87-25-Oregon.hfc.comcastbusiness.net ([75.148.87.25]:22144
	"EHLO chris.i8u.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbbDIA0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 20:26:05 -0400
In-Reply-To: <alpine.NEB.2.11.1504081705350.3388@chris.i8u.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Apr 2015, Hisashi T Fujinaka wrote:

> On Wed, 8 Apr 2015, Alexander Duyck wrote:
>> 
>> It is but it isn't.  If you look in e1000_change_mtu you will find the
>> node about "Jumbo frame workaround on 82579 and newer requires CRC be
>> stripped".  With that being the case I'm wondering if the 9018 doesn't
>> include CRC but instead includes VLAN header.  So as a result the actual
>> hardware is processing frames that are 9022 in size, but the buffer only
>> ever receives at most 9018 since the CRC is stripped.
>> 
>> I suspect that is why the Windows driver has had no issues reporting
>> support for a size of 9014 (excluding VLAN and CRC) on these parts and
>> hasn't had any issues.
>
> I can only tell you what was told to me by Dave Ertman, which is that
> there is a hard hardware limit of 9018 bytes. I wouldn't know if we do
> have Windows issues because it's a completely different division and
> there's no reason for any of those issues to be routed to us.
>
> In fact, the problem with different max MTU across the drivers in Linux
> has only ever been reported by one user.
>
> I'm still looking for the HW documentation and would like Jeff to hold
> off until we find it.

OK. So the data sheet states:

LPE controls whether long packet reception is permitted. Hardware
discards long packets if LPE is 0. A long packet is one longer than 1522
bytes. If LPE is 1, the maximum packet size that the device can receive
is 9018 bytes.

So if you're pre-stripping the CRC, then it will be less than 9018.

I guess I'd like to hear what Dave thinks.
