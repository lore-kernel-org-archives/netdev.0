From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] e100: Fix inconsistency in bad frames
	handling
Date: Mon, 06 Jun 2011 13:20:57 -0700
Message-ID: <4DED36A9.9080500@candelatech.com>
References: <BANLkTimpYniHhN6ccMXN7Lx3xDdK6sC+FQ@mail.gmail.com>	
	<alpine.WNT.2.00.1106060940010.3568@JBRANDEB-DESK2.amr.corp.intel.com>	
	<4DED14E7.2050405@candelatech.com>
	<1307391315.22348.454.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrea Merello <andrea.merello@gmail.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1307391315.22348.454.camel@localhost>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 06/06/2011 01:15 PM, Ben Hutchings wrote:
> On Mon, 2011-06-06 at 10:56 -0700, Ben Greear wrote:
>> On 06/06/2011 10:49 AM, Brandeburg, Jesse wrote:
>>>
>>> <added netdev>, removed other useless lists.
>>>
>>> On Sat, 4 Jun 2011, Andrea Merello wrote:
>>>> In e100 driver it seems that the intention was to accept bad frames in
>>>> promiscuous mode and loopback mode.
>>>> I think this is evident because of the following code in the driver:
>>>>
>>>> if (nic->flags&   promiscuous || nic->loopback) {
>>>> 		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
>>>> 		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
>>>> 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
>>>> 	}
>>>>
>>>
>>> Hi, thanks for your work on e100.
>>>
>>>> However this intention is not really realized because bad frames are
>>>> discarded later by SW check.
>>>> This patch finally honors the above intention, making the RX code to
>>>> let bad frames to pass when the NIC is in promiscuous or loopback
>>>> mode.
>>>
>>> I think this may be a mistake by the authors of the software developers
>>> manual.  The manual suggests that save bad frames and save short frames
>>> should be enabled in promisc mode, but all of our other drivers *do not*
>>> save bad frames when in promiscuous mode (by design).  This is intentional
>>> because a bad frame is just that, bad, and with no hope of knowing if the
>>> data in it is okay/malicious/other.  I understand your reasoning above,
>>> but realistically the rx_save_bad_frames should NOT be set.  I'd ack a
>>> patch to comment that line out.
>>>
>>>> This helped me a lot to debug an FPGA ethernet core.
>>>> Maybe it can be also useful to someone else..
>>>
>>> I think this patch is just that, debug only. As a developer I understand
>>> why this is useful, but there is no reason any normal user would be able
>>> to benefit from this, so for now, sorry:
>>>
>>> NACK.
>>
>> I think anyone sniffing a funky network would have benefit in
>> receiving all frames.  So, while it shouldn't be enabled by default,
>> it would be nice to have an ethtool command to turn on receiving
>> bad-crc frames, as well as receiving the 4-byte CRC on the end of
>> the packets.
>>
>> It just so happens I have such a patch, in case others agree :)
>
> How would a received skb be flagged as having a CRC error?

We could add an skb flag?  Or just pass it straight up and let
the receiving code deal with it (if we pass up the CRC as well, receiving
code has all info needed).

There are other errors possible as well, I think...maybe short frames, etc,
so it might be nice to have some way to mark what the NIC thinks is wrong
with the pkt.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
Simplify data backup and recovery for your virtual environment with vRanger.
Installation's a snap, and flexible recovery options mean your data is safe,
secure and there when you need it. Discover what all the cheering's about.
Get your free trial download today. 
http://p.sf.net/sfu/quest-dev2dev2 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
