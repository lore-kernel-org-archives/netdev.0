From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront:
 correct	MAX_TX_TARGET	calculation.
Date: Fri, 03 Feb 2012 13:26:47 +0000
Message-ID: <4F2BEEA70200007800070E81@nat28.tlf.novell.com>
References: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>
 <20120126181900.GB25572@phenom.dumpdata.com>
 <1327660589.2585.14.camel@leeni.uk.xensource.com>
 <4F2BD2CC.4050906@redhat.com> <4F2BDA4C.7060601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>, "Laszlo Ersek" <lersek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:46300 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088Ab2BCN0u convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:6:1>);
	Fri, 3 Feb 2012 08:26:50 -0500
In-Reply-To: <4F2BDA4C.7060601@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 03.02.12 at 13:59, Laszlo Ersek <lersek@redhat.com> wrote:
> On 02/03/12 13:27, Laszlo Ersek wrote:
>> On 01/27/12 11:36, Wei Liu wrote:
> 
>>> As the tx structure is bigger than rx structure. I think scratch space
>>> size is likely to shrink after correction.
>>
>> It also seems to affect the netfront_tx_slot_available() function,
>> making it stricter (likely). Before the patch, the function may have
>> reported available slots when there were none, causing spurious(?) queue
>> wakeups in xennet_maybe_wake_tx(), and not stopping the queue in
>> xennet_start_xmit() when it should have(?).
> 
> (Eyeballing the source makes me think
> 
>    NET_TX_RING_SIZE == (4096 - 16 - 48) / (5 * 4) == 201
>    NET_RX_RING_SIZE == (4096 - 16 - 48) / (4 * 4) == 252

NET_TX_RING_SIZE == (4096 - 16 - 48) / (6 * 2) == 336
NET_RX_RING_SIZE == (4096 - 16 - 48) / (4 * 2) == 504

and with {R,T}X_MAX_TARGET capped to 256 the change really is
benign without multi-page ring support afaict.

Jan

> but I didn't try to verify them.)
> 
> Laszlo
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xensource.com 
> http://lists.xensource.com/xen-devel 
