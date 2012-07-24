From: Ben Greear <greearb@candelatech.com>
Subject: Re: Crash in e1000e, 3.3.8+ (tainted)
Date: Tue, 24 Jul 2012 16:20:56 -0700
Message-ID: <500F2DD8.8030300@candelatech.com>
References: <500F17A0.30906@candelatech.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89130D50549@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, bruce.w.allan@intel.com
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89130D50549@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 07/24/2012 04:13 PM, Dave, Tushar N wrote:
>> -----Original Message-----
>> From: Ben Greear [mailto:greearb@candelatech.com]
>> Sent: Tuesday, July 24, 2012 2:46 PM
>> To: e1000-devel list; netdev
>> Subject: [E1000-devel] Crash in e1000e, 3.3.8+ (tainted)
>>
>> We have a somewhat reproducible crash using a 6-port NIC with 3.3.8+
>> kernel.  This kernel is tainted with a proprietary module, but the module
>> is not in use.
>>
>> The rx-all and related patches that were later accepted upstream have been
>> applied to this kernel.
>>
>> It seems that buffer_info is NULL in the code below?
>>
>>
>> (gdb) list e1000_alloc_rx_buffers+0x5b
>> Junk at end of line specification.
>> (gdb) list *(e1000_alloc_rx_buffers+0x5b)
>> 0x15822 is in e1000_alloc_rx_buffers (/home/greearb/git/linux-
>> 3.3.dev.y/drivers/net/ethernet/intel/e1000e/netdev.c:611).
>> 606
>> 607		i = rx_ring->next_to_use;
>> 608		buffer_info = &rx_ring->buffer_info[i];
>> 609
>> 610		while (cleaned_count--) {
>> 611			skb = buffer_info->skb;
>> 612			if (skb) {
>> 613				skb_trim(skb, 0);
>> 614				goto map_skb;
>> 615			}
>> (gdb)
>>
>>
> Ben,
>
> This looks familiar to me, I believe this is due to race between adapter reset and e1000_close.
> Let me check if we have fix upstream or not.

I'm testing Bruce Allen's suggestion now:  bb9e44d0 (from 3.4).

It applies with fuzz to my 3.3.8+ tree.

So far, so good...but need to do some more reboots to be sure.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com




------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
