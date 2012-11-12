From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH v3 3/9] net: xfrm: use __this_cpu_read per-cpu helper
Date: Mon, 12 Nov 2012 09:45:56 +0800
Message-ID: <50A054D4.2070404@gmail.com>
References: <509C688B.5010502@gmail.com> <0000013ae6ccff86-695eb9f4-23b6-4196-a575-e12d05e1a659-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0000013ae6ccff86-695eb9f4-23b6-4196-a575-e12d05e1a659-000000@email.amazonses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter said, at 2012/11/10 4:12:
> On Fri, 9 Nov 2012, Shan Wei wrote:
> 
>> v3 fix compile warning:
>> net/xfrm/xfrm_ipcomp.c: In function 'ipcomp_alloc_tfms':
>> net/xfrm/xfrm_ipcomp.c:285: warning: assignment from incompatible pointer type
> 
> Why exactly is the pointer type not compatible? Looks like we have a
> problem here.
> 

pos->tfms(struct crypto_comp **tfms) is a double pointer that point to struct crypto_comp.
returned value is a pointer that point to struct crypto_comp;
So, we need to dereference and then read.

+ tfm = __this_cpu_read(*pos->tfms);

I will update this patch in v4 to fix it.

Thanks~
