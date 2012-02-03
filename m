From: Laszlo Ersek <lersek@redhat.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: correct MAX_TX_TARGET	calculation.
Date: Fri, 03 Feb 2012 13:27:56 +0100
Message-ID: <4F2BD2CC.4050906@redhat.com>
References: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>	<20120126181900.GB25572@phenom.dumpdata.com> <1327660589.2585.14.camel@leeni.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232Ab2BCM0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 07:26:31 -0500
In-Reply-To: <1327660589.2585.14.camel@leeni.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/12 11:36, Wei Liu wrote:
> On Thu, 2012-01-26 at 18:19 +0000, Konrad Rzeszutek Wilk wrote:
>> On Thu, Jan 26, 2012 at 05:23:23PM +0000, Wei Liu wrote:
>>
>> Can you give some more details please? What is the impact of
>> not having this? Should it be backported to stable?
>>
>
> I think it will not cause crash, only the scratch space size is
> affected, thus impacting tx batching a bit.
>
> As the tx structure is bigger than rx structure. I think scratch space
> size is likely to shrink after correction.

It also seems to affect the netfront_tx_slot_available() function, 
making it stricter (likely). Before the patch, the function may have 
reported available slots when there were none, causing spurious(?) queue 
wakeups in xennet_maybe_wake_tx(), and not stopping the queue in 
xennet_start_xmit() when it should have(?).

It seems there are no further uses of TX_MAX_TARGET, and for bounds 
checking NET_TX_RING_SIZE was used (which was always correct). So I 
guess the typo may have caused some performance degradation.

I can't either prove or disprove a DoS-like busy loop in the pre-patch form.

Laszlo
