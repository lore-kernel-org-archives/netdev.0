From: "Karicheri, Muralidharan" <m-karicheri2@ti.com>
Subject: RE: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
Date: Tue, 9 Feb 2016 16:55:42 +0000
Message-ID: <3E54258959B69E4282D79E01AB1F32B704D12E49@DFLE11.ent.ti.com>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCDBFCC@AcuExch.aculab.com>
 <3E54258959B69E4282D79E01AB1F32B704D12AF4@DFLE11.ent.ti.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCDC14B@AcuExch.aculab.com>
 <3E54258959B69E4282D79E01AB1F32B704D12B40@DFLE11.ent.ti.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCDC216@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Cooper Jr., Franklin" <fcooper@ti.com>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"Strashko, Grygorii" <grygorii.strashko@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	"Arnd Bergmann" <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCDC216@AcuExch.aculab.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: David Laight [mailto:David.Laight@ACULAB.COM]
>Sent: Tuesday, February 09, 2016 11:38 AM
>To: Karicheri, Muralidharan; Strashko, Grygorii; netdev@vger.kernel.org; David S . Miller;
>Arnd Bergmann
>Cc: Cooper Jr., Franklin; Nori, Sekhar; linux-kernel@vger.kernel.org; Kwok, WingMan; N,
>Mugunthan V
>Subject: RE: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
>
>From: Karicheri, Muralidharan
>> Sent: 09 February 2016 16:19
>> >...
>> >> >In reality the 'pad' fields ought to be renamed - since they aren't pads.
>> >> >Perhaps they should be a union?
>> >
>> >> No. At the end of the descriptor, host software can add scratchpad
>> >> which is not modified by the hardware, but is used by the driver.
>> >> So please don't rename.
>> >
>> >So comment in the definition that the hardware doesn't modify them.
>> >The driver is defining these fields and they are definitely NOT padding.
>>
>>
>> It is scratch pad, not padding. Looks like pad is a confusing name.
>> Can be renamed to sw_data to be in sync with spec below.
>>
>> The hardware spec from
>> http://www.ti.com/lit/ug/sprugr9h/sprugr9h.pdf
>>
>> The other SW data portion of the descriptor exists after all of the
>> defined words and is reserved for use by the host software to store
>> completely private data. This region is not used in any way by the DMA
>> or queue manager modules in a Multicore Navigator system and these
>> modules will not modify any bytes within this region.
>
>Right, so comment that the hardware doesn't look at the fields.
>But name/type the structure fields to indicate what they contain.
>Maybe sw_buf_len etc - but I suspect there are much more meaningful names.

The descriptors are usable by different drivers, one driver may use it as 
buf ptr/ len, other for something else. So they should remain as generic
and it is up to individual drivers to use it in whatever way it requires.
My suggestion is to rename pad field in struct knav_dma_desc to sw_data
to avoid confusion. i.e 

+       __le32  pad[4];

to 

+       __le32  sw_data[4];

Murali
>
>	David
