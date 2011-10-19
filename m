From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot device
Date: Wed, 19 Oct 2011 13:53:42 -0700
Message-ID: <4E9F38D6.6030700@intel.com>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com> <20111019.160653.684945718064985511.davem@davemloft.net> <1319055172.7658.33.camel@HP1> <20111019.164702.1494656842101009040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "mchan@broadcom.com" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dmitry@broadcom.com" <dmitry@broadcom.com>,
	"eilong@broadcom.com" <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63820 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486Ab1JSUxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 16:53:45 -0400
In-Reply-To: <20111019.164702.1494656842101009040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2011 1:47 PM, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 19 Oct 2011 13:12:52 -0700
> 
>>
>> On Wed, 2011-10-19 at 13:06 -0700, David Miller wrote:
>>> From: "Michael Chan" <mchan@broadcom.com>
>>> Date: Thu, 13 Oct 2011 20:38:01 -0700
>>>
>>>> From: Dmitry Kravkov <dmitry@broadcom.com>
>>>>
>>>> For an FCoE or iSCSI boot device, the networking side must stay "up" all
>>>> the time.  Otherwise, the FCoE/iSCSI interface driven by bnx2i/bnx2fc
>>>> will be reset and we'll lose the root file system.
>>>>
>>>> If LRO is enabled, scripts that enable IP forwarding or bridging will
>>>> disable LRO and cause the device to be reset.  Disabling LRO on these
>>>> boot devices will prevent the reset.
>>>>
>>>> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>>>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>>>
>>> You're still going to have bugs after this.
>>>
>>> What if you get a FIFO overflow or other error condition which requires
>>> a chip reset?  You'll lose the root filesystem.
>>
>> That would be no different than a scsi driver experiencing fatal errors,
>> wouldn't it?
> 
> It's not fatal if you can bring the chip back up after the reset
> because this is networking.
> 
> These things are protocols, built on top of networking technology,
> with retransmits, handshakes, and all sorts of features designed
> to provide reliability.
> 
> Things like a LRO change ought to be completely transparent.

As a reference point this works fine in both FCoE and iSCSI stacks
today. The device is reset or link is lost for whatever reason
when the link comes back up the stack logs back in, enumerates
the luns and the scsi stack recovers as expected.

Firmware should do the equivalent login, lun enumeration, etc as
needed.

.John
