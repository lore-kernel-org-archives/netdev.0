From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [RFC v2] iwlwifi: pcie: transmit queue auto-sizing
Date: Thu, 4 Feb 2016 12:45:57 -0800
Message-ID: <56B3B885.1050409@candelatech.com>
References: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
 <1454616988-21901-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
To: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454616988-21901-1-git-send-email-emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/04/2016 12:16 PM, Emmanuel Grumbach wrote:
> As many (all?) WiFi devices, Intel WiFi devices have
> transmit queues which have 256 transmit descriptors
> each and each descriptor corresponds to an MPDU.
> This means that when it is full, the queue contains
> 256 * ~1500 bytes to be transmitted (if we don't have
> A-MSDUs). The purpose of those queues is to have enough
> packets to be ready for transmission so that when the device
> gets an opportunity to transmit (TxOP), it can take as many
> packets as the spec allows and aggregate them into one
> A-MPDU or even several A-MPDUs if we are using bursts.

I guess this is only really usable if you have exactly one
peer connected (ie, in station mode)?

Otherwise, you could have one slow peer and one fast one,
and then I suspect this would not work so well?

For reference, ath10k has around 1400 tx descriptors, though
in practice not all are usable, and in stock firmware, I'm guessing
the NIC will never be able to actually fill up it's tx descriptors
and stop traffic.  Instead, it just allows the stack to try to
TX, then drops the frame...

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
