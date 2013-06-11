From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers/net/ethernet/3com: Drop EISA dependency from
 VORTEX
Date: Wed, 12 Jun 2013 00:45:54 +0400
Message-ID: <51B78C82.7020709@cogentembedded.com>
References: <1370962642-12097-1-git-send-email-markos.chandras@imgtec.com> <51B75088.8050800@windriver.com> <CAG2jQ8hACp_iGEXR7rXKR3sydK4O=y0paeh1FFgH2UisxWVxVA@mail.gmail.com> <51B78594.5050903@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Markos Chandras <markos.chandras@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B78594.5050903@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/12/2013 12:16 AM, Paul Gortmaker wrote:

>>>> The Vortex driver depends on PCI with optional support for EISA.

>>>> This fixes build problems when EISA is selected but not PCI.

>>>> drivers/net/ethernet/3com/3c59x.c:1031:2: error: implicit declaration of
>>>> function 'pci_iomap' [-Werror=implicit-function-declaration]
>>>> drivers/net/ethernet/3com/3c59x.c:1044:3: error: implicit declaration of
>>>> function 'pci_iounmap' [-Werror=implicit-function-declaration]

>>>> Cc: David S. Miller <davem@davemloft.net>
>>>> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
>>>> Cc: netdev@vger.kernel.org
>>>> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
>>>> ---
>>>>   drivers/net/ethernet/3com/Kconfig | 2 +-
>>>>   1 file changed, 1 insertion(+), 1 deletion(-)

>>>> diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
>>>> index 1c71c76..5c67f44 100644
>>>> --- a/drivers/net/ethernet/3com/Kconfig
>>>> +++ b/drivers/net/ethernet/3com/Kconfig
>>>> @@ -66,7 +66,7 @@ config PCMCIA_3C589
>>>>
>>>>   config VORTEX
>>>>        tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
>>>> -     depends on (PCI || EISA) && HAS_IOPORT
>>>> +     depends on PCI && HAS_IOPORT

>>> How can this fix it?  The way I read your change is that you
>>> have now made it impossible to select for EISA=y and PCI=n,
>>> thus breaking EISA only configurations who would find their
>>> driver support gone when they run "make oldconfig".

[...]

>> Hi Paul,

>> The driver does not seem to build if you only have EISA=y and PCI=n.
>> Does this driver really support EISA only

> Yes.  Not that anyone really probably cares anymore.  EISA is dead.

    We have the user of 3Com EISA cards on this list and I've fixed EISA
specific bug in this driver not long ago.

WBR, Sergei
