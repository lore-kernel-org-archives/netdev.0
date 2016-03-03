From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V3] net: ezchip: adapt driver to little endian architecture
Date: Thu, 03 Mar 2016 15:11:26 +0100
Message-ID: <2080435.sC07a7uq9e@wuerfel>
References: <1457014066-27651-1-git-send-email-ltrimas@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>
To: Lada Trimasova <Lada.Trimasova@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457014066-27651-1-git-send-email-ltrimas@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 03 March 2016 17:07:46 Lada Trimasova wrote:
> From:	Lada Trimasova <Lada.Trimasova@synopsys.com>
> To:	netdev@vger.kernel.org
> CC:	linux-kernel@vger.kernel.org, Lada Trimasova <Lada.Trimasova@synopsys.com>, Alexey Brodkin <Alexey.Brodkin@synopsys.com>, Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>, Arnd Bergmann <arnd@arndb.de>
> Date:	Today 15:07:46
> Since ezchip network driver is written with big endian EZChip platform it
> is necessary to add support for little endian architecture.
> 
> The first issue is that the order of the bits in a bit field is
> implementation specific. So all the bit fields are removed.
> Named constants are used to access necessary fields.
> 
> And the second one is that network byte order is big endian.
> For example, data on ethernet is transmitted with most-significant
> octet (byte) first. So in case of little endian architecture
> it is important to swap data byte order when we read it from
> register. In case of unaligned access we can use "get_unaligned_be32"
> and in other case we can use function "ioread32_rep" which reads all
> data from register and works either with little endian or big endian
> architecture.
> 
> And then when we are going to write data to register we need to restore
> byte order using the function "put_unaligned_be32" in case of
> unaligned access and in other case "iowrite32_rep".
> 
> The last little fix is a space between type and pointer to observe
> coding style.
> 
> Signed-off-by: Lada Trimasova <ltrimas@synopsys.com>
> Cc: Alexey Brodkin <abrodkin@synopsys.com>
> Cc: Noam Camus <noamc@ezchip.com>
> Cc: Tal Zilcer <talz@ezchip.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
