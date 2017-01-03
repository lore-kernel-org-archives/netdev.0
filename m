From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: consider inserted data in genlmsg_end
Date: Tue, 03 Jan 2017 11:10:28 -0500 (EST)
Message-ID: <20170103.111028.1485189939139437925.davem@davemloft.net>
References: <20170103003910.8984-1-wr0112358@gmail.com>
        <20170103.095419.261470619535526723.davem@davemloft.net>
        <20170103160443.GC11735@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wr0112358@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170103160443.GC11735@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 3 Jan 2017 11:04:43 -0500

> On Tue, Jan 03, 2017 at 09:54:19AM -0500, David Miller wrote:
>> From: Reiter Wolfgang <wr0112358@gmail.com>
>> Date: Tue,  3 Jan 2017 01:39:10 +0100
>> 
>> > Final nlmsg_len field update must reflect inserted net_dm_drop_point
>> > data.
>> > 
>> > This patch depends on previous patch:
>> > "drop_monitor: add missing call to genlmsg_end"
>> > 
>> > Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>
>> 
>> I don't understand why the current code doesn't work properly.
>> 
>> All over the tree, the pattern is:
>> 
>> 	x = genlmsg_put(skb, ...);
>> 	...
>> 	genlmsg_end(skb, x);
>> 
>> And that is exactly what the code is doing right now.
>> 
> 
> Because reset_per_cpu_data should close the use of of the established skb
> that was being written to.  Without this patch we add the END tlv to the skb
> that is just getting started for use in the drop monitor, rather than for the
> skb that is getting returned for use in sending up to user space listeners.
> 
> Or am I missing something?

That's the critical part I didn't see, thanks for explaining.

Applied and queued up for -stabel, thanks.
