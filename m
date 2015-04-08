From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [PATCH] e1000e: Cleanup handling of VLAN_HLEN as a part of max
 frame size
Date: Wed, 8 Apr 2015 16:05:45 -0700 (PDT)
Message-ID: <alpine.NEB.2.11.1504081602260.3388@chris.i8u.org>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org> <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22> <alpine.NEB.2.11.1504081413510.3388@chris.i8u.org> <5525B2AE.80301@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, mike@cchtml.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-148-87-25-Oregon.hfc.comcastbusiness.net ([75.148.87.25]:16416
	"EHLO chris.i8u.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbbDHXFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 19:05:46 -0400
In-Reply-To: <5525B2AE.80301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Apr 2015, Alexander Duyck wrote:

> On 04/08/2015 02:15 PM, Hisashi T Fujinaka wrote:
>> On Wed, 8 Apr 2015, Alexander Duyck wrote:
>>
>>> Fixes: c751a3d58cf2d ("e1000e: Correctly include VLAN_HLEN when
>>> changing interface MTU")
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>>> ---
>>>
>>> I have only build tested this though I am 99% sure the fixes here are
>>> correct.  This patch should fix issues on 82573 and ich8 w/ setting
>>> an MTU
>>> of 1500, and for the PCH series w/ setting an MTU of 9000.
>>
>> Since the original fix was something submitted by Red Hat, can you check
>> that you're not re-breaking whatever it was that Red Hat thought they
>> were fixing?
>
> The original issue is referenced in the patch that this fixes.  The
> problem was that the VLAN header wasn't being considered when computing
> the Rx buffer size, so you could change the MTU to 1504 and the if
> statement at the end of e1000_change_mtu was still using a 1522 Rx
> buffer size and max frame even though we had technically just configured
> things for 1526.
>
> The updated logic is correctly taking the VLAN header into account so if
> you bump the MTU 1504 it will switch over to jumbo frames mode w/ 2K
> buffers.
>
> The bit I am fixing is that there were several spots including the
> backend value for max_hw_frame_size that didn't take VLAN header length
> into account.  There were cases where 1500 MTU was being treated as a
> jumbo frame, or we were coming up 4 bytes shy as in the pch2, ich8, and
> 82573 e1000_info structures.

The max_hw_frame_size should still be limited to 9018.
