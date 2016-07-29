From: Andre Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH v2 1/5] ethernet: add sun8i-emac driver
Date: Fri, 29 Jul 2016 11:12:02 +0100
Message-ID: <0dbea4a5-6f76-5dc2-6745-dccea31072ef@arm.com>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
 <1469001800-11615-2-git-send-email-clabbe.montjoie@gmail.com>
 <20160725195455.GQ7419@lukather>
Reply-To: andre.przywara-5wv7dgnIgG8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
   linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
   linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
   LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDNZNK75ZIKRBR6X5S6AKGQE5CXRMPA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20160725195455.GQ7419@lukather>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hi,

On 25/07/16 20:54, Maxime Ripard wrote:
> On Wed, Jul 20, 2016 at 10:03:16AM +0200, LABBE Corentin wrote:
>> This patch add support for sun8i-emac ethernet MAC hardware.
>> It could be found in Allwinner H3/A83T/A64 SoCs.
>>
>> It supports 10/100/1000 Mbit/s speed with half/full duplex.
>> It can use an internal PHY (MII 10/100) or an external PHY
>> via RGMII/RMII.
>>
>> Signed-off-by: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  drivers/net/ethernet/allwinner/Kconfig      |   13 +
>>  drivers/net/ethernet/allwinner/Makefile     |    1 +
>>  drivers/net/ethernet/allwinner/sun8i-emac.c | 2129 +++++++++++++++++++++++++++
>>  3 files changed, 2143 insertions(+)
>>  create mode 100644 drivers/net/ethernet/allwinner/sun8i-emac.c

...

>> diff --git a/drivers/net/ethernet/allwinner/sun8i-emac.c b/drivers/net/ethernet/allwinner/sun8i-emac.c
>> new file mode 100644
>> index 0000000..fc0c1dd
>> --- /dev/null
>> +++ b/drivers/net/ethernet/allwinner/sun8i-emac.c

...

>> +
>> +/* struct dma_desc - Structure of DMA descriptor used by the hardware
>> + * @status: Status of the frame written by HW, so RO for the
>> + *	driver (except for BIT(31) which is R/W)
>> + * @ctl: Information on the frame written by the driver (INT, len,...)
>> + * @buf_addr: physical address of the frame data
>> + * @next: physical address of next dma_desc
>> + */
>> +struct dma_desc {
>> +	u32 status;
>> +	u32 ctl;
>> +	u32 buf_addr;
>> +	u32 next;
>> +};
> 
> You should use the endian-aware variants here.

For the records: just doing the sparse annotation with __le32 here will
of course not be sufficient to make it work on BE kernels. I added
proper endianness conversion to all accesses to the descriptors and got
it to work with an arm64 big-endian kernel on the Pine64.

I put a patch here:
https://gist.github.com/apritzel/bc792c4dbbd8789f5f18aef538e8c440

This particular version is untested (though it compiles), since I just
adapted the working patch against the newer driver code and couldn't
test it yet.
I am not really an endianness expert, so don't know if there are smarter
ways to tackle this, if we should for instance provide access wrappers
to the DMA descriptor fields.

I will try to test this later today, if that works, feel free to merge
those changes into your driver.

Cheers,
Andre.
