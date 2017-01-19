From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 0/7] Clean up PHY MMD accessors
Date: Thu, 19 Jan 2017 11:42:47 -0800
Message-ID: <9fb97d58-6ad3-f9d1-c255-9f91e5857f88@gmail.com>
References: <20170113152059.GR14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Woojung Huh <woojung.huh@microchip.com>, netdev@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170113152059.GR14217@n2100.armlinux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 01/13/2017 07:20 AM, Russell King - ARM Linux wrote:
> This series cleans up phylib's MMD accessors, so that we have a common
> way of accessing the Clause 45 register set.
> 
> The current situation is far from ideal - we have phy_(read|write)_mmd()
> which accesses Clause 45 registers over Clause 45 accesses, and we have
> phy_(read|write)_mmd_indirect(), which accesses Clause 45 registers via
> Clause 22 register 13/14.
> 
> Generic code uses the indirect methods to access standard Clause 45
> features, and when we come to add Clause 45 PHY support to phylib, we
> would need to make these conditional upon the PHY type, or duplicate
> these functions.
> 
> An alternative solution is to merge these accessors together, and select
> the appropriate access method depending upon the 802.3 clause that the
> PHY conforms with.  The result is that we have a single set of
> phy_(read|write)_mmd() accessors.
> 
> For cases which require special handling, we still allow PHY drivers to
> override all MMD accesses - except rather than just overriding the
> indirect accesses.  This keeps existing overrides working.
> 
> Combining the two also has another beneficial side effect - we get rid
> of similar functions that take arguments in different orders.  The
> old direct accessors took the phy structure, devad and register number,
> whereas the indirect accessors took the phy structure, register number
> and devad in that order.  Care must be taken when updating future
> drivers that the argument order is correct, and the function name is
> not merely replaced.

I really like that series, this is much much cleaner, do you mind
resubmitting this without a RFC tag so David can apply it?

Thanks!
-- 
Florian
