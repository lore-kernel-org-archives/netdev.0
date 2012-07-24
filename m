From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: [E1000-devel] Crash in e1000e, 3.3.8+ (tainted)
Date: Tue, 24 Jul 2012 23:23:31 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89130D505BF@ORSMSX102.amr.corp.intel.com>
References: <500F17A0.30906@candelatech.com>
 <061C8A8601E8EE4CA8D8FD6990CEA89130D50549@ORSMSX102.amr.corp.intel.com>
 <500F2DD8.8030300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61795 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754997Ab2GXXXd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 19:23:33 -0400
In-Reply-To: <500F2DD8.8030300@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Ben Greear [mailto:greearb@candelatech.com]
>Sent: Tuesday, July 24, 2012 4:21 PM
>To: Dave, Tushar N
>Cc: e1000-devel list; netdev; Allan, Bruce W
>Subject: Re: [E1000-devel] Crash in e1000e, 3.3.8+ (tainted)
>
>On 07/24/2012 04:13 PM, Dave, Tushar N wrote:
>>> -----Original Message-----
>>> From: Ben Greear [mailto:greearb@candelatech.com]
>>> Sent: Tuesday, July 24, 2012 2:46 PM
>>> To: e1000-devel list; netdev
>>> Subject: [E1000-devel] Crash in e1000e, 3.3.8+ (tainted)
>>>
>>> We have a somewhat reproducible crash using a 6-port NIC with 3.3.8+
>>> kernel.  This kernel is tainted with a proprietary module, but the
>>> module is not in use.
>>>
>>> The rx-all and related patches that were later accepted upstream have
>>> been applied to this kernel.
>>>
>>> It seems that buffer_info is NULL in the code below?
>>>
>>>
>>> (gdb) list e1000_alloc_rx_buffers+0x5b Junk at end of line
>>> specification.
>>> (gdb) list *(e1000_alloc_rx_buffers+0x5b)
>>> 0x15822 is in e1000_alloc_rx_buffers (/home/greearb/git/linux-
>>> 3.3.dev.y/drivers/net/ethernet/intel/e1000e/netdev.c:611).
>>> 606
>>> 607		i = rx_ring->next_to_use;
>>> 608		buffer_info = &rx_ring->buffer_info[i];
>>> 609
>>> 610		while (cleaned_count--) {
>>> 611			skb = buffer_info->skb;
>>> 612			if (skb) {
>>> 613				skb_trim(skb, 0);
>>> 614				goto map_skb;
>>> 615			}
>>> (gdb)
>>>
>>>
>> Ben,
>>
>> This looks familiar to me, I believe this is due to race between adapter
>reset and e1000_close.
>> Let me check if we have fix upstream or not.
>
>I'm testing Bruce Allen's suggestion now:  bb9e44d0 (from 3.4).

Yep, commit bb9e44d0 the one.
>
>It applies with fuzz to my 3.3.8+ tree.
>
>So far, so good...but need to do some more reboots to be sure.
>
>Thanks,
>Ben
>
>--
>Ben Greear <greearb@candelatech.com>
>Candela Technologies Inc  http://www.candelatech.com
>
>
