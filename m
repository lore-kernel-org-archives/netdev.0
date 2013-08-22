From: boris brezillon <b.brezillon@overkiz.com>
Subject: Re: [RFC PATCH] phylib: mdio: handle register/unregister/register
 sequence
Date: Thu, 22 Aug 2013 17:38:30 +0200
Message-ID: <52163076.2010501@overkiz.com>
References: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com> <20130822152757.GA23163@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Nick Bowler <nbowler@elliptictech.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130822152757.GA23163@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/08/2013 17:27, Greg Kroah-Hartman wrote:
> On Thu, Aug 22, 2013 at 02:33:56PM +0200, Boris BREZILLON wrote:
>> Hello,
>>
>> This patch is a proposal to support the register/unregister/register
>> sequence on a given mdio bus.
>>
>> I use the register/unregister/register sequence to add a fallback when the
>> of_mdiobus_register (this function calls mdiobus_register with phy_mask
>> set to ~0) does not register any phy device (because the device tree does
>> not define any phy).
>> In this case I call mdiobus_unregister and then call mdiobus_register with
>> a phy_mask set to 0 to trigger a full mdio bus scan.
>>
>> I'm not sure this is the right way to do it (this is why I added RFC in the
>> subject).
>>
>> Could someone help me figuring out what I should use to implement my fallback ?
>>
>> 1) use the register/unregister/register sequence
> That will not work.  Well, you might think it would work, but then
> things randomly start breaking later on.  Try it with the
> KOBJECT_DELAYED_DESTROY build option in linux-next, and watch things go
> "boom" :)
>
> The rule is, you should never register a kobject/struct device that you
> have previously unregistered before, as you really don't know if
> unregistering has finished or not.

Thanks for your answer.

>
> sorry,
>
> greg k-h
