From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
	driver
Date: Tue, 26 May 2009 16:23:47 +0200
Message-ID: <4A1BFB73.4020305@grandegger.com>
References: <200905242327.15139.arnd@arndb.de>	<4A1A418D.3040207@grandegger.com>	<200905261010.31364.arnd@arndb.de>
	<20090526.022508.238274281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, devicetree-discuss@ozlabs.org, arnd@arndb.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090526.022508.238274281.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Tue, 26 May 2009 10:10:30 +0100
> 
>> On Monday 25 May 2009, Wolfgang Grandegger wrote:
>>>> Right, that makes sense. However, most drivers use the field to store the
>>>> physical address, not the iomap token. Maybe there should be a new field
>>>> in struct sja1000_priv for the virtual address, but that would be a change
>>>> to the base driver, not just to the OF portion.
>>> Is that common practice? If yes, I will add a member to store the
>>> virtual address to struct sja1000_priv.
>> I grepped through the network driver for usage of ->base_addr, and
>> it's somewhat inconsistent. The majority of the users use it for
>> a physical address, but there are also a few that use it for the
>> __iomem token.
>>
>> Casts between unsigned long and qualified (__iomem, __user, const, ...)
>> pointers do not cause a warning, but can easily lead to bugs when
>> another user casts to an unqualified pointer.
> 
> It's such a baroque thing, there is no reason to set it at all if you
> ask me.  It's only use is to allow ISA and similar primitive bus
> devices to have their I/O ports changed via ifconfig.

OK, I see, there are good reasons not to (mis-)use dev->base_addr. I
will prepare a patch for the SJA1000 CAN drivers.

Wolfgang.
