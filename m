From: Kevin Hilman <khilman@ti.com>
Subject: Re: [PATCH] net: davinci_emac: Add pre_open, post_stop platform callbacks
Date: Thu, 03 May 2012 07:22:34 -0700
Message-ID: <87sjfhmjit.fsf@ti.com>
References: <20120502234718.GA5432@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Mark A. Greer" <mgreer@animalcreek.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Bedia\, Vaibhav" <vaibhav.bedia@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
	(Vaibhav Bedia's message of "Thu, 3 May 2012 10:44:44 +0000")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Bedia, Vaibhav" <vaibhav.bedia@ti.com> writes:

> On Thu, May 03, 2012 at 05:17:18, Mark A. Greer wrote:
>> From: "Mark A. Greer" <mgreer@animalcreek.com>
>> 
>> The davinci EMAC driver has been incorporated into the am35x
>> family of SoC's which is OMAP-based.  The incorporation is
>> incomplete in that the EMAC cannot unblock the [ARM] core if
>> its blocked on a 'wfi' instruction.  This is an issue with
>> the cpu_idle code because it has the core execute a 'wfi'
>> instruction.
>> 
>> To work around this issue, add platform data callbacks which
>> are called at the beginning of the open routine and at the
>> end of the stop routine of the davinci_emac driver.  The
>> callbacks allow the platform code to issue disable_hlt() and
>> enable_hlt() calls appropriately.  Calling disable_hlt()
>> prevents cpu_idle from issuing the 'wfi' instruction.
>> 
>> It is not sufficient to simply call disable_hlt() when
>> there is an EMAC present because it could be present but
>> not actually used in which case, we do want the 'wfi' to
>> be executed.
>> 
>
> Are you trying to say that if ARM executes _just_ wfi and _absolutely
> nothing else_ is done in the OMAP PM code, EMAC stops working?
>
> However, if this is indeed the case, then probably a better solution would be
> to invoke disable_hlt() from the board file when EMAC support is compiled in.

No.  As Mark stated in the changelog, doing that will prevent any
low-power states states even if the EMAC is not in use.  IMO, it is best
to only prevent WFI when absolutely needed.

Kevin

