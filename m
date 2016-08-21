From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan-cosa: Use memdup_user() rather than duplicating
 its implementation
Date: Sat, 20 Aug 2016 19:12:33 -0700 (PDT)
Message-ID: <20160820.191233.1040358497240261402.davem@davemloft.net>
References: <5d335025-5f52-d4b6-0b60-89a2fd354694@users.sourceforge.net>
        <np956e$tnp$1@blaine.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <np956e$tnp$1@blaine.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sat, 20 Aug 2016 10:42:54 +0200

> Le 20/08/2016 à 10:25, SF Markus Elfring a écrit :
>> @@ -875,16 +875,10 @@ static ssize_t cosa_write(struct file *file,
>>   	if (count > COSA_MTU)
>>   		count = COSA_MTU;
>>   	
>> -	/* Allocate the buffer */
>> -	kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA);
> In this case, 'memdup_user()' has a different meaning, as GFP_DMA will
> no more be used for this memory allocation.

Agreed, this transformation is not equivalent.

Markus, please do not make these changes so blindly.
