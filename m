From: "Seewer Philippe" <philippe.seewer@bfh.ch>
Subject: Re: [PATCH 1/2] pcnet32: Introduce basic AT 2700/01 FTX support
Date: Fri, 17 Feb 2006 21:12:52 +0100
Message-ID: <43F62E44.2090109@bfh.ch>
References: <43F5F66F.6040608@bfh.ch> <20060217182104.GA19257@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <tsbogend@alpha.franken.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751681AbWBQUNK@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Don Fry" <brazilnut@us.ibm.com>
In-Reply-To: <20060217182104.GA19257@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Don Fry wrote:
> Philippe,
> 
> On a purely mechanical note, the patches do not apply cleanly because
> of whitespace changes.  Possibly your mailer changed tabs to spaces,
> which causes the patch not to apply, and also causes your patch to have
> different spacing than the rest of the file.  The driver does not
> conform to the 8-space indentation guideline/rule, but it is consistent
> in 4-space indentation.
uhhh.... did i forget to run Lindent..? Or was it that i just
selected-middle clicked them into thunderbird?
what's the recommended procedure oh how to append patches to
mails? (Documentation just says included not attached...)
> 
> I am looking over this change and the following one, to try and
> understand what and why you made your changes.
> 
> The change made by Thomas Bogendoerfer and modified by myself is much
> more flexible than your changes, in that they are not specific just to
> the Allied Telesyn boards with multiple Phys.
I'm not sure what you are talking about. I didn't see any PHY switching
code in the driver... And the specs specifically say that when more than
one PHY is connected control should revert to software.

> They also allow dynamic
> changing of cabling without requiring the driver to be removed/installed
> or the card power cycled.  I also see little value in the module
> parameters, when it can be determined dynamically. Also, maxphy might be
> thought to the the maximum number of phys, rather than the maximum phy
> number supported.  If static selection of the phy to use is passed in as
> a module parameter, why also include a maxphy?
maxphy is supposed to be how many PHYs are actually connected to the chip.
I didn't want to introduce a generic PHY scanner (which is possible)
because that would have haa impact on all cards not only cards that actually
have more than one phy.

I really tried to put this into pcnet32_open. But i just didn't work...

> 
> As I review your patches I will follow up to the mailing list.
> 
> On Fri, Feb 17, 2006 at 05:14:39PM +0100, Seewer Philippe wrote:
> 
>>This patch extends Don Fry's last patch for AT 2700/01 FX to set the
>>speed/fdx options for the FTX variants of these cards as well.
>>
>>Additionally the option override has been moved from pcnet32_open to
>>pcnet32_probe1 because it's only necessary to override the options once.
>>
>>Tested and works.
>>
>>Patch applies to 2.6.16-rc3
>>
> 
> Don Fry
> brazilnut@us.ibm.com
