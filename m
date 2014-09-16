From: Sandeep Nair <sandeep_n@ti.com>
Subject: Re: [PATCH v3 2/3] net: Add Keystone NetCP ethernet driver
Date: Tue, 16 Sep 2014 09:44:59 -0400
Message-ID: <54183EDB.20801@ti.com>
References: <1410638839-14792-1-git-send-email-santosh.shilimkar@ti.com>	<1410638839-14792-3-git-send-email-santosh.shilimkar@ti.com> <20140915.123755.1868053059646672094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <robh+dt@kernel.org>,
	<grant.likely@linaro.org>, <devicetree@vger.kernel.org>,
	<jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>, <santosh.shilimkar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140915.123755.1868053059646672094.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/15/2014 12:37 PM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Date: Sat, 13 Sep 2014 16:07:18 -0400
>
>> +	/* Find this module in the sub-tree for this device */
>> +	devices = of_get_child_by_name(node, "netcp-devices");
>> +	if (!devices) {
>> +		dev_err(dev, "could not find netcp-devices node\n");
>> +		return NETCP_MOD_PROBE_SKIPPED;
>> +	}
>> +
>> +	for_each_available_child_of_node(devices, child) {
>> +		const char *name = netcp_node_name(child);
>> +
>> +		if (!strcasecmp(module->name, name))
>> +			break;
>> +	}
>> +
>> +	/* If module not used for this device, skip it */
>> +	if (child == NULL) {
>> +		dev_warn(dev, "module(%s) not used for device\n", module->name);
>> +		return NETCP_MOD_PROBE_SKIPPED;
>> +	}
>
> of_get_child_by_name() takes a reference to an OF node, you must release
> it in the error path.
>
Will fix this.
>> +	inst_modpriv = devm_kzalloc(dev, sizeof(*inst_modpriv), GFP_KERNEL);
>> +	if (!inst_modpriv) {
>> +		dev_err(dev, "Failed to allocate instance for %s\n",
>> +			module->name);
>> +		return -ENOMEM;
>> +	}
>
> Likewise, but here you have to release both "devices" and "child".
>
> You're going to have to fix this OF node refcount problem for this
> entire probe routine.
>
Will do.

Thanks for the review David!

Regards
Sandeep
