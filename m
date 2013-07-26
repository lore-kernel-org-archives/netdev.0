From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Fri, 26 Jul 2013 15:56:18 -0700 (PDT)
Message-ID: <20130726.155618.987909338861687509.davem@davemloft.net>
References: <1374857234-1442-1-git-send-email-nhorman@tuxdriver.com>
	<8761vxfefj.fsf@canonical.com>
	<20130726170251.GC11633@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130726170251.GC11633@hmsreliant.think-freely.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 26 Jul 2013 13:02:51 -0400

> On Fri, Jul 26, 2013 at 05:56:16PM +0100, Luis Henriques wrote:
>> Neil Horman <nhorman@tuxdriver.com> writes:
>> 
>> > atl1c uses netdev_alloc_skb to refill its rx dma ring, but that call makes no
>> > guarantees about the suitability of the memory for use in DMA.  As a result
>> > we've gotten reports of atl1c drivers occasionally hanging and needing to be
>> > reset:
>> > https://bugzilla.kernel.org/show_bug.cgi?id=54021
>> >
>> > Fix this by modifying the call to use the internal version __netdev_alloc_skb,
>> > where you can set the gfp_mask explicitly to include GFP_DMA.
>> >
>> > Tested by two reporters in the above bug, who have the hardware to validate it.
>> > Both report immediate cessation of the problem with this patch
>> >
>> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> > CC: Jay Cliburn <jcliburn@gmail.com>
>> > CC: "David S. Miller" <davem@davemloft.net>
>> > CC: stable@vger.kernel.org
>> > Tested-by: Luis Henrix <luis.henrix@gmail.com>
>> 
>> Thanks Neil!
>> 
>> Would it be possible for you to update my name and email?  (I've just
>> updated my bz account to remove my gmail account address -- I thought
>> I had done this ages ago.)
>> 
>> Tested-by: Luis Henriques <luis.henriques@canonical.com>
>> 
> I'm sure if Dave has time, he will square that up.

I took care of this while applying Neil's patch, thanks.
