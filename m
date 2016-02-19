From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH v1 1/4] net: ti: netcp: restore get/set_pad_info()
 functionality
Date: Fri, 19 Feb 2016 13:01:59 -0500
Message-ID: <56C75897.5080103@ti.com>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
 <7111317.k6f7A38a4k@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7111317.k6f7A38a4k@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/19/2016 09:41 AM, Arnd Bergmann wrote:
> On Thursday 18 February 2016 14:46:14 Murali Karicheri wrote:
>> From: Arnd Bergmann <arnd@arndb.de>
>>
>> The commit 899077791403 ("netcp: try to reduce type confusion in
>> descriptors") introduces a regression in Kernel 4.5-rc1 and it breaks
>> get/set_pad_info() functionality.
>>
>> The TI NETCP driver uses pad0 and pad1 fields of knav_dma_desc to
>> store DMA/MEM buffer pointer and buffer size respectively. And in both
>> cases for Keystone 2 the pointer type size is 32 bit regardless of
>> LAPE enabled or not, because CONFIG_ARCH_DMA_ADDR_T_64BIT originally
>> is not expected to be defined.
>>
>> 			!LAPE	LPAE
>> sizeof(void*)		32bit	32bit
>> sizeof(dma_addr_t) 	32bit	32bit
>> sizeof(phys_addr_t) 	32bit	64bit
> 
> As this was never relevant or true, I don't think it needs to be
> mentioned here, it just confuses things. Please just assume that
> dma_addr_t can be 64-bit wide, but will only contain 32-bit
> numbers on keystone.
> 
>> Unfortunately, above commit changed buffer's pointers save/restore
>> code (get/set_pad_info()) and added intermediate conversation to u64
>> which works incorrectly on 32bit Keystone 2 and causes TI NETCP driver
>> crash in RX/TX path due to "Unable to handle kernel NULL pointer"
>> exception. This issue was reported and discussed in [1].
> 
> Have you been able to figure out why it actually broke? I'd still
> like to know.
> 
I have just send v2. I will investigate your original patch that added
regression this afternoon and respond with my observation as soon as
my investigation is complete. I assume, you are trying to make the change
such that the virtual pointers stored in sw_data/pad works across
32bit and 64bit machine, right? 

Murali

>> Hence, fix it by partially reverting above commit and restoring
>> get/set_pad_info() functionality as it was before.
>>
>> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg95361.html
>> Cc: Wingman Kwok <w-kwok2@ti.com>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> CC: David Laight <David.Laight@ACULAB.COM>
>> Reported-by: Franklin S Cooper Jr <fcooper@ti.com>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> 
> I don't think I sent this patch with a 'Signed-off-by', did I?
> (I could be misremembering that).
> 
> 	Arnd
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
