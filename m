From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Sat, 25 Feb 2012 21:28:05 -0500 (EST)
Message-ID: <20120225.212805.1394065389987976077.davem@davemloft.net>
References: <1330201304-24037-1-git-send-email-stigge@antcom.de>
 <20120226015217.GA3257@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stigge@antcom.de, alexander.h.duyck@intel.com, ian.campbell@citrix.com,
 netdev@vger.kernel.org, eilong@broadcom.com, kevin.wells@nxp.com,
 w.sang@pengutronix.de, jeffrey.t.kirsher@intel.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: baruch@tkos.co.il
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20120226015217.GA3257@tarshish>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Baruch Siach <baruch@tkos.co.il>
Date: Sun, 26 Feb 2012 03:52:18 +0200

> Hi Roland,
> 
> On Sat, Feb 25, 2012 at 09:21:44PM +0100, Roland Stigge wrote:
>> This patch adds an ethernet driver for the LPC32xx ARM SoC.
>> 
>> Signed-off-by: Roland Stigge <stigge@antcom.de>
> 
> [snip]
> 
>> +static int __init ethaddr(char *s)
>> +{
>> +	int i;
>> +	unsigned int r[6];
>> +
>> +	sscanf(s, "%x:%x:%x:%x:%x:%x",
>> +			&r[0], &r[1], &r[2], &r[3], &r[4], &r[5]);
>> +	for (i = 0; i < 6; i++)
>> +		mac_address[i] = (u8)r[i];
>> +
>> +	return 1;
>> +}
>> +__setup("ethaddr=", ethaddr);
> 
> Please use a module_param() instead of a top level kernel parameter.

Actually, remove this entirely, we don't add module parameters
to force the ethernet address.  That should be done in userland
in some fashion.

We've had many discussions about this recently, and this is the
consistent policy we want to enforce in all drivers from now on.
