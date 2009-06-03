From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Tue, 02 Jun 2009 17:14:18 -0700 (PDT)
Message-ID: <20090602.171418.186096253.davem@davemloft.net>
References: <1243885642.22917.35.camel@pohly-MOBL>
	<20090602.002553.143476036.davem@davemloft.net>
	<200906022338.30618.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rolandd@cisco.com, libertas-dev@lists.infradead.org, dcbw@redhat.com,
        netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        patrick.ohly@intel.com, divy@chelsio.com, xemul@openvz.org
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200906022338.30618.rusty@rustcorp.com.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 2 Jun 2009 23:38:29 +0930

> On Tue, 2 Jun 2009 04:55:53 pm David Miller wrote:
>> From: Patrick Ohly <patrick.ohly@intel.com>
>> Date: Mon, 01 Jun 2009 21:47:22 +0200
>>
>> > On Fri, 2009-05-29 at 23:44 +0930, Rusty Russell wrote:
>> >> This patch adds skb_orphan to the start of dev_hard_start_xmit(): it
>> >> can be premature in the NETDEV_TX_BUSY case, but that's uncommon.
>> >
>> > Would it be possible to make the new skb_orphan() at the start of
>> > dev_hard_start_xmit() conditionally so that it is not executed for
>> > packets that are to be time stamped?
>> >
>> > As discussed before
>> > (http://article.gmane.org/gmane.linux.network/121378/), the skb->sk
>> > socket pointer is required for sending back the send time stamp from
>> > inside the device driver. Calling skb_orphan() unconditionally as in
>> > this patch would break the hardware time stamping of outgoing packets.
>>
>> Indeed, we need to check that case, at a minimum.
>>
>> And there are other potentially other problems.  For example, I
>> wonder how this interacts with the new TX MMAP af_packet support
>> in net-next-2.6 :-/
> 
> I think I'll do this in the driver for now, and let's revisit doing it 
> generically later?

That might be the best course of action for the time being.
This whole area is a rat's nest.
