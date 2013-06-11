From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers/net/ethernet/3com: Drop EISA dependency from
 VORTEX
Date: Tue, 11 Jun 2013 22:09:52 +0400
Message-ID: <51B767F0.6020304@cogentembedded.com>
References: <1370962642-12097-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370962642-12097-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11-06-2013 18:57, Markos Chandras wrote:

> The Vortex driver depends on PCI with optional support for EISA.

> This fixes build problems when EISA is selected but not PCI.

> drivers/net/ethernet/3com/3c59x.c:1031:2: error: implicit declaration of
> function 'pci_iomap' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/3com/3c59x.c:1044:3: error: implicit declaration of
> function 'pci_iounmap' [-Werror=implicit-function-declaration]

> Cc: David S. Miller <davem@davemloft.net>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>

    The proper way to address this is probably add empty *static inline* 
function implementations for CONFIG_PCI=n case to the header file, same 
as was done with pci_{request|release}_regions() for this same file 
several years ago...

WBR, Sergei
