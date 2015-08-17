From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF is
 configured or used
Date: Mon, 17 Aug 2015 17:35:00 -0500
Message-ID: <55D26194.5060702@arm.com>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
 <55D24FEE.8040505@arm.com> <55D25CE0.6040203@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55D25CE0.6040203@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2015 05:14 PM, Guenter Roeck wrote:
> One nitpick I noticed after sending my patch: dev can never be NULL in
> smsc911x_probe_config(), so it does not really make sense to check if it is NULL.

No, it doesn't... it should really be something like

if (dev_fwnode(dev))

But dev_fwnode is static inline in property.c, and i'm pretty sure that 
still isn't 100% correct.The best plan might just be to remove the 
check, and abort on failure to find the phy property per your patch.
