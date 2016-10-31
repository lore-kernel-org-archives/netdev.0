From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 1/1] xen-netfront: do not cast grant
 table reference to signed short
Date: Mon, 31 Oct 2016 02:44:15 -0600
Message-ID: <5817126F020000780011AEDF@prv-mh.provo.novell.com>
References: <21bd3cd7-68ed-45cd-9728-73c88c79fe65@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <xen-devel@lists.xenproject.org>,
        <boris.ostrovsky@oracle.com>, "Juergen Gross" <JGross@suse.com>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Dongli Zhang" <dongli.zhang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:51499 "EHLO
        prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762362AbcJaIoU (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:5:2>);
        Mon, 31 Oct 2016 04:44:20 -0400
In-Reply-To: <21bd3cd7-68ed-45cd-9728-73c88c79fe65@default>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 31.10.16 at 09:28, <dongli.zhang@oracle.com> wrote:
>> >                  ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
>> > -                BUG_ON((signed short)ref < 0);
>> > +                WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));
> 
>> You really need to cast to plain (or signed) long here - casting to
>> unsigned long will work only in 32-bit configurations, as otherwise
>> you lose the sign of the value.
> 
> Seems the sign of value would not be lost since casting to unsigned long will
> use signed extension. Is my understanding wrong or did I miss anything?

ref being of type grant_ref_t, which is a typedef of uint32_t, I can't
see how the conversion to unsigned long would be using sign
extension. Did you look at the generated code? (If ref was of a signed
type, I don't think the original author would have found a need to cast
it to signed short.)

> I have verified this with both sample userspace helloworld program
> and a kernel module.

Are you saying you did see the warning trigger with a 64-bit kernel?
I'd be very surprised, but of course I may be overlooking something.

Jan
