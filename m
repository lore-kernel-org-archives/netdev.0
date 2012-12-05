From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/macb: increase RX buffer size for GEM
Date: Wed, 5 Dec 2012 16:08:22 +0100
Message-ID: <50BF6366.8080600@atmel.com>
References: <1354536943-6356-1-git-send-email-nicolas.ferre@atmel.com> <20121204.132227.1430662061932892582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <manabian@gmail.com>,
	<plagnioj@jcrosoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121204.132227.1430662061932892582.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/2012 07:22 PM, David Miller :
> From: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date: Mon, 3 Dec 2012 13:15:43 +0100
> 
>> Macb Ethernet controller requires a RX buffer of 128 bytes. It is
>> highly sub-optimal for Gigabit-capable GEM that is able to use
>> a bigger DMA buffer. Change this constant and associated macros
>> with data stored in the private structure.
>> I also kept the result of buffers per page calculation to lower the
>> impact of this move to a variable rx buffer size on rx hot path.
>> RX DMA buffer size has to be multiple of 64 bytes as indicated in
>> DMA Configuration Register specification.
>>
>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> This looks like it will waste a couple hundred bytes for 1500 MTU
> frames, am I right?

Yep! But buffers get recycled, and with the current memory management by
pages, it seems that I have to rework some part of it to optimize this
memory usage (8KB memory blocks split into 5 buffers each as David said...).

Do you think it is worth digging this way or may I rework the rx buffer
management in case of the GEM interface. If I implement a different path
for GEM interface, I will have the possibility to tailor rx DMA buffers
from 1500 Bytes up to 10KB jumbo frames...

Best regards,
-- 
Nicolas Ferre
