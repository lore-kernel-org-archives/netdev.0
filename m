From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 23/23 V2 for 3.19]  rtlwifi: Fix error when accessing
 unmapped memory in skb
Date: Tue, 30 Dec 2014 21:31:47 -0600
Message-ID: <54A36E23.2000804@lwfinger.net>
References: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net> <20141231004947.GA2007@zzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20141231004947.GA2007@zzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/30/2014 06:49 PM, Eric Biggers wrote:
> On Sat, Dec 27, 2014 at 02:17:37PM -0600, Larry Finger wrote:
>> These drivers use 9100-byte receive buffers, thus allocating an skb requires
>> an O(3) memory allocation. Under heavy memory loads and fragmentation, such
>> a request can fail. Previous versions of the driver have dropped the packet
>> and reused the old buffer; however, the new version introduced a bug in that
>> it released the old buffer before trying to allocate a new one. The previous
>> method is implemented here.
>
> It looks like in the out-of-memory path, pci_map_single() gets called while the
> skb is still mapped.  Won't this leak the IOMMU mapping?

Good catch. I do not know much about leaking the IOMMU mapping; however it is 
easy to do the unmapping before trying to allocate a new skb.

Thanks,

Larry
