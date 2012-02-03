From: Laszlo Ersek <lersek@redhat.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: correct	MAX_TX_TARGET	calculation.
Date: Fri, 03 Feb 2012 13:59:56 +0100
Message-ID: <4F2BDA4C.7060601@redhat.com>
References: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>	<20120126181900.GB25572@phenom.dumpdata.com>	<1327660589.2585.14.camel@leeni.uk.xensource.com> <4F2BD2CC.4050906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366Ab2BCM6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 07:58:32 -0500
In-Reply-To: <4F2BD2CC.4050906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/12 13:27, Laszlo Ersek wrote:
> On 01/27/12 11:36, Wei Liu wrote:

>> As the tx structure is bigger than rx structure. I think scratch space
>> size is likely to shrink after correction.
>
> It also seems to affect the netfront_tx_slot_available() function,
> making it stricter (likely). Before the patch, the function may have
> reported available slots when there were none, causing spurious(?) queue
> wakeups in xennet_maybe_wake_tx(), and not stopping the queue in
> xennet_start_xmit() when it should have(?).

(Eyeballing the source makes me think

   NET_TX_RING_SIZE == (4096 - 16 - 48) / (5 * 4) == 201
   NET_RX_RING_SIZE == (4096 - 16 - 48) / (4 * 4) == 252

but I didn't try to verify them.)

Laszlo
