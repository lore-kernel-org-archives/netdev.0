From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH v4 3/9] net: xfrm: use __this_cpu_read per-cpu helper
Date: Tue, 13 Nov 2012 17:33:19 +0800
Message-ID: <50A213DF.1040103@gmail.com>
References: <50A1A7C9.3060703@gmail.com> <20121113072101.GG22290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121113072101.GG22290@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steffen Klassert said, at 2012/11/13 15:21:
> 
> This should just fetch the tfm pointer, so why exactly __this_cpu_read
> is better than __this_cpu_ptr? Please keep in mind that performance is
> not the most important thing here. It's much more important that it
> works in any case.
 
[0/9] describes why we should submit this series patches.
you are not included in original mail.

this_cpu_ptr relocates and address. this_cpu_read() relocates the address
and performs the fetch. If you want to operate on rda(defined as per_cpu) 
then you can only use this_cpu_ptr. this_cpu_read() saves you more instructions
since it can do the relocation and the fetch in one instruction.

More info, please refer to http://www.spinics.net/lists/kernel/msg1435153.html
