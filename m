From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [RFC v2] iwlwifi: pcie: transmit queue auto-sizing
Date: Thu, 4 Feb 2016 13:14:13 -0800
Message-ID: <56B3BF25.8080509@candelatech.com>
References: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
 <1454616988-21901-1-git-send-email-emmanuel.grumbach@intel.com>
 <56B3B885.1050409@candelatech.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32EA02656@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32EA02656-Jy8z56yoSI9wl47ZQwxUxrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/04/2016 12:56 PM, Grumbach, Emmanuel wrote:
>
>
> On 02/04/2016 10:46 PM, Ben Greear wrote:
>> On 02/04/2016 12:16 PM, Emmanuel Grumbach wrote:
>>> As many (all?) WiFi devices, Intel WiFi devices have
>>> transmit queues which have 256 transmit descriptors
>>> each and each descriptor corresponds to an MPDU.
>>> This means that when it is full, the queue contains
>>> 256 * ~1500 bytes to be transmitted (if we don't have
>>> A-MSDUs). The purpose of those queues is to have enough
>>> packets to be ready for transmission so that when the device
>>> gets an opportunity to transmit (TxOP), it can take as many
>>> packets as the spec allows and aggregate them into one
>>> A-MPDU or even several A-MPDUs if we are using bursts.
>> I guess this is only really usable if you have exactly one
>> peer connected (ie, in station mode)?
>>
>> Otherwise, you could have one slow peer and one fast one,
>> and then I suspect this would not work so well?
>
> Yes. I guess this one (big) limitation. I guess that what would happen
> in this case is that the the latency would constantly jitter. But I also
> noticed that I could reduce the transmit queue to 130 descriptors
> (instead of 256) and still reach maximal throughput because we can
> refill the queues quickly enough.
> In iwlwifi, we have plans to have one queue for each peer.
> This is under development. Not sure when it'll be ready. It also requires
> firmware change obviously.

Per-peer queues will probably be nice, especially if we can keep the
buffer bloat manageable.

>> For reference, ath10k has around 1400 tx descriptors, though
>> in practice not all are usable, and in stock firmware, I'm guessing
>> the NIC will never be able to actually fill up it's tx descriptors
>> and stop traffic.  Instead, it just allows the stack to try to
>> TX, then drops the frame...
>
> 1400 descriptors, ok... but they are not organised in queues?
> (forgive my ignorance of athX drivers)

I think all the details are in the firmware, at least for now.

The firmware details are probably not something I should go into, but suffice it to say
its complex and varies between firmware versions in non-trivial ways.

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
