From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: TX from KVM guest virtio_net to vhost issues
Date: Wed, 16 Mar 2011 17:20:14 -0700
Message-ID: <1300321214.3255.40.camel@localhost.localdomain>
References: <1299707197.25664.173.camel@localhost.localdomain>
	 <87d3ly2n81.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:43698 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422Ab1CQAU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 20:20:26 -0400
In-Reply-To: <87d3ly2n81.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-11 at 16:49 +1030, Rusty Russell wrote:
> But if one side outruns the other, it does a lot of unnecessary work
> notifying/interrupting it over and over again before the host/guest
> gets
> a chance to shut notifications/interrupts off.  Hence the last_used
> publishing patch (Xen does this right, I screwed it up).
> 
> Long weekend here, and I'm otherwise committed.  But if noone has
> cleaned up that patch by early next week, I'll try to do so and see if
> we can make a real difference.

This patch doesn't seem to help guest TX queue overrun. I couldn't find
any other reason why the TX queue overrun, even I increased guest send
queue ring size to 1K, it didn't help at all. I sent out a dropping
packet approach for guest to avoid this for you to review. Small message
size performance has been dramatically increased with a few packet
drops. Most of the workload doesn't invoke the TX queue overrun, so I
don't see any regressions. 

With this patch, vhost side doesn't need to signal guest on TX path,
however for previous guest, we still need vhost to signal guest.

Please let me know if you have any other ideas to debug what causes
guest TX overrun.

Thanks
Shirley

