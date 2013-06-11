From: Markos Chandras <markos.chandras@gmail.com>
Subject: Re: [PATCH] drivers/net/ethernet/3com: Drop EISA dependency from VORTEX
Date: Tue, 11 Jun 2013 19:28:34 +0100
Message-ID: <CAG2jQ8iic-u-kKpGp+OrcrHB2eDdpNsENw25BWxZiD6oDA1dNA@mail.gmail.com>
References: <1370962642-12097-1-git-send-email-markos.chandras@imgtec.com> <51B767F0.6020304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B767F0.6020304@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 June 2013 19:09, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 11-06-2013 18:57, Markos Chandras wrote:
>
>> The Vortex driver depends on PCI with optional support for EISA.
>
>
>> This fixes build problems when EISA is selected but not PCI.
>
>
>> drivers/net/ethernet/3com/3c59x.c:1031:2: error: implicit declaration of
>> function 'pci_iomap' [-Werror=implicit-function-declaration]
>> drivers/net/ethernet/3com/3c59x.c:1044:3: error: implicit declaration of
>> function 'pci_iounmap' [-Werror=implicit-function-declaration]
>
>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
>
>
>    The proper way to address this is probably add empty *static inline*
> function implementations for CONFIG_PCI=n case to the header file, same as
> was done with pci_{request|release}_regions() for this same file several
> years ago...
>
> WBR, Sergei
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Hi Sergei,

Sounds reasonable to me but I am not that familiar with this part of
the kernel so I can't comment on whether this is the best solution or
not.

--
Regards,
Markos Chandras
