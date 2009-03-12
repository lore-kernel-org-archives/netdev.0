From: Michael Cashwell <mboards@prograde.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 09:41:38 -0400
Message-ID: <F884D8C3-E35B-4239-8D72-165EE528FCAC@prograde.net>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
	<20090310211841.388619ca@nehalam>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ilya Yanok <yanok@emcraft.com>, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <20090310211841.388619ca@nehalam>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

On Mar 11, 2009, at 12:18 AM, Stephen Hemminger wrote:

> On Wed, 11 Mar 2009 05:29:09 +0300
> Ilya Yanok <yanok@emcraft.com> wrote:
>
>> +static char ethaddr[18];
>> +
>> +module_param_string(ethaddr, ethaddr, sizeof(ethaddr), 0);
>> +
>> +static void get_mac_addr(struct net_device *nd, unsigned char *pmac)
>> +{
>> +	int i;
>> +	char *p = ethaddr;
>> +
>> +	ethaddr[17] = 0;
>> +	for (i = 0; i < ETH_ALEN; i++, p++) {
>> +		pmac[i] = simple_strtoul(p, &p, 16);
>> +		if (*p != ':')
>> +			break;
>> +	}
>> +	if (i != ETH_ALEN - 1) {
>> +		pr_err("Wrong MAC address format!\n");
>> +		memset(pmac, 0, ETH_ALEN);
>> +	}
>> +}
>> +
>
> Do you still need this? Only works with one board, configuration via
> module parameters is discouraged.  Same effect can be done by setting
> mac address with regular tools.

I'm confused by this. If I'm NFS-booting the board then how do I get  
to those userland tools if I don't have a valid MAC address in place  
to do the root mount?

-Mike


-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
