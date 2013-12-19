From: Leigh Brown <leigh@solinno.co.uk>
Subject: Re: [PATCH v2] net: mvmdio: fix interrupt timeout handling
Date: Thu, 19 Dec 2013 19:35:01 +0000
Message-ID: <aff941cf1be9b91cc58198b4c23a3e41@doppler.thel33t.co.uk>
References: <52B2D97F.4070200@gmail.com>
 <1387458588-17231-1-git-send-email-leigh@solinno.co.uk>
 <20131219174334.GB10227@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Nicolas Schichan <nschichan@freebox.fr>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131219174334.GB10227@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-12-19 17:43, Jason Gunthorpe wrote:
> On Thu, Dec 19, 2013 at 01:09:48PM +0000, Leigh Brown wrote:
>> This version corrects the whitespace issue.
>> 
>> orion_mdio_wait_ready uses wait_event_timeout to wait for the
>> SMI interrupt to fire.  wait_event_timeout waits for between
>> "timeout - 1" and "timeout" jiffies.  In this case a 1ms timeout
>> when HZ is 1000 results in a wait of 0 to 1 jiffies, causing
>> premature timeouts.
>> 
>> This fix ensures a minimum timeout of 2 jiffies, ensuring
>> wait_event_timeout will always wait at least 1 jiffie.
>> 
>> Issue reported by Nicolas Schichan.
>> 
>> Tested-by: Nicolas Schichan <nschichan@freebox.fr>
>> Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
>>  drivers/net/ethernet/marvell/mvmdio.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
> 
> Leigh, I have just noticed a regression in 3.13-rc3 vs 3.10, on
> kirkwood where 3.13 occasionally prints:
> 
> 3 12/11 13:59:02 kernel: orion-mdio f1072004.mdio: Timeout: SMI busy
> for too long
> 
> Is that the same issue that this patch is addressing?

Yes, absolutely.

Regards,

Leigh.
