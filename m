From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next V5 0/9] Altera Triple Speed Ethernet (TSE) Driver
Date: Sat, 15 Mar 2014 15:52:15 -0500
Message-ID: <CAOwfj2P4EWHmVgOVM=seUnwBpHupyGoeh5aM-X-tC8tXhWTjkQ@mail.gmail.com>
References: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
	<20140314.150720.734350362080616095.davem@davemloft.net>
	<20140314.151524.753884730788957176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140314.151524.753884730788957176.davem@davemloft.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave

On Fri, Mar 14, 2014 at 2:15 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 14 Mar 2014 15:07:20 -0400 (EDT)
>
>> From: Vince Bridgers <vbridgers2013@gmail.com>
>> Date: Fri, 14 Mar 2014 09:04:38 -0500
>>
>>> This is the version 5 submission for the Altera Triple Speed Ethernet (TSE)
>>> driver. All comments received during the version 2, 3, and 4 submissions have
>>> been accepted. Please find the change log and a description of the submission
>>> below.
>>
>> Series applied to net-next, thanks.
>
> Actually, I had to revert, your driver adds new warnings to the build:
>
> drivers/net/ethernet/altera/altera_tse_main.c: In function 'altera_tse_probe':
> drivers/net/ethernet/altera/altera_tse_main.c:1238:23: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>    priv->tx_dma_desc = (void *)descmap;
>                        ^
> drivers/net/ethernet/altera/altera_tse_main.c:1242:23: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>    priv->rx_dma_desc = (void *)(descmap+priv->txdescmem);
>                        ^
>
> A pointer can be larger than an "unsigned int", you therefore cannot
> cast it to a pointer.
>
> In fact this code path has a lot of problems, we pass a pointer to an unsigned int
> as a "void __iomem *" to request_and_map().  It's not, don't pretend that it is,
> and don't use casts to try and make the compiler also not see the problem.

Thank for catching this, another oversight on my part. I'll address
the issue in our pre-submission process, correct the problem and
resubmit. For what it's worth, we did not see the compiler warnings
before submitting.

All the best,

Vince
