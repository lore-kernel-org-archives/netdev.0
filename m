From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] net, thunder, bgx: Add support for ACPI binding.
Date: Sat, 08 Aug 2015 13:26:23 +0200
Message-ID: <2414262.jivbxTLuUW@wuerfel>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com> <55C467A0.4020601@linaro.org> <20150807104320.GQ1820@rric.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Robert Richter <robert.richter@caviumnetworks.com>,
        Tomasz Nowicki <tomasz.nowicki@linaro.org>,
        linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-acpi@vger.kernel.org, David Daney <ddaney.cavm@gmail.com>,
        Sunil Goutham <sgoutham@cavium.com>,
        "David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20150807104320.GQ1820@rric.localhost>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Friday 07 August 2015 12:43:20 Robert Richter wrote:
> 
> I would not pollute bgx_probe() with acpi and dt specifics, and instead
> keep bgx_init_phy(). The typical design pattern for this is:
> 
> static int bgx_init_phy(struct bgx *bgx)
> {
> #ifdef CONFIG_ACPI
>         if (!acpi_disabled)
>                 return bgx_init_acpi_phy(bgx);
> #endif
>         return bgx_init_of_phy(bgx);
> }
> 
> This adds acpi runtime detection (acpi=no), does not call dt code in
> case of acpi, and saves the #else for bgx_init_acpi_phy().
> 

What you should really do is to use the same function for both,
using the generic device properties API. If that is not possible,
explain in a comment why not.

Aside from that, if you do have to use compile-time conditionals,
use 'if (IS_ENABLED(CONFIG_ACPI) && !acpi_disabled)' instead of
#ifdef, for readability. The compiler will produce the same binary,
but also give helpful warnings about incorrect code that you don't
get with #ifdef.

	Arnd
