From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net] ixgbe: Only set gso_type to SKB_GSO_TCPV4 as RSC
 does not support IPv6
Date: Tue, 12 Feb 2013 13:39:03 -0800
Message-ID: <511AB677.9060708@intel.com>
References: <20130212193624.17818.13843.stgit@ahduyck-cp1.jf.intel.com> <20130212205151.GC6972@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64678 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab3BLVjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 16:39:09 -0500
In-Reply-To: <20130212205151.GC6972@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2013 12:51 PM, Michael S. Tsirkin wrote:
> On Tue, Feb 12, 2013 at 11:45:44AM -0800, Alexander Duyck wrote:
>> The original fix that was applied for setting gso_type required more change
>> than necessary because it was assumed ixgbe does RSC on IPv6 frames and this
>> is not correct.  RSC is only supported with IPv4/TCP frames only.  As such we
>> can simplify the fix and avoid the unnecessary move of eth_type_trans.
>>
>> The previous patch "ixgbe: fix gso type" and this patch reduce the entire fix
>> to one line that sets gso_type to TCPV4 if the frame is RSC.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Is this architectural? Is it safe to assume there won't be an update
> that does RSC on IPv6?

If there is an update at some point in the future we could address it
then.  I just wanted to keep changes to net minimal to avoid a possible
regression, and this patch does that.  No point in future proofing it
for features we may or may not implement at some point in the future.

If we were to add IPv6 support to RSC it would be a serious rewrite of
the feature anyway.  This code would hopefully be refactored as a part
of that rewrite since we would want the hardware to give us the MSS
instead of making us have to approximate it.

Thanks,

Alex
