From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1 v3] drivers: net: rmnet: Initial
 implementation
Date: Fri, 14 Apr 2017 15:57:22 -0600
Message-ID: <4549f41894889b5c11411dfb429e5f36@codeaurora.org>
References: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
 <1492146329-4304-2-git-send-email-subashab@codeaurora.org>
 <20170414090752.GA1992@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52382 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754794AbdDNV5Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 17:57:24 -0400
In-Reply-To: <20170414090752.GA1992@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No, please use standard facilities in order to do debug logging.
> 
>> +static struct rmnet_logical_ep_conf_s *_rmnet_get_logical_ep
> 
> Dont use "_" at the start of a name without purpose
> 
>> +static int rmnet_associate_network_device(struct net_device *dev)
> 
> I would expect to see here you making connection between real_dev and
> rmnet dev. I don't see such thing. Name of the function is misleading.
> 
>> +
>> +	config = kmalloc(sizeof(*config), GFP_ATOMIC);
> 
> kzalloc, and you don't have to zero the memory.
> 
>> +static struct notifier_block rmnet_dev_notifier = {
> 
> You should add "__read_mostly"
> 
>> +	.notifier_call = rmnet_config_notify_cb,
>> +	.next = 0,
>> +	.priority = 0
> 
> This initialization of 0s is not needed.
> 
>> +/* rmnet_vnd_is_vnd() gives mux_id + 1, so subtract 1 to get the 
>> correct mux_id
>> + */
> 
> Fix this comment format.
>> +void rmnet_print_packet(const struct sk_buff *skb, const char *dev, 
>> char dir)
> 
> No reason to have this function. One can use P_ALL tap to get skbs to
> userspace.
> 
>> +/* rmnet_bridge_handler() - Bridge related functionality
>> + */
> 
> Fix the comment format (you have it on multiple places)
> 
>> +static rx_handler_result_t rmnet_bridge_handler
>> +	(struct sk_buff *skb, struct rmnet_logical_ep_conf_s *ep)
> 
> The formatting is incorrect:
> 
> static rx_handler_result_t
> rmnet_bridge_handler(struct sk_buff *skb, struct 
> rmnet_logical_ep_conf_s *ep)
> 
> 
>> +	config = (struct rmnet_phys_ep_conf_s *)
>> +		rcu_dereference(skb->dev->rx_handler_data);
>> +
>> +	if (!config) {
> 
> Cannot happen. Please remove this.
> 
>> +	.ndo_set_mac_address = 0,
>> +	.ndo_validate_addr = 0,
> 
> These are NULL by default. No need to init.
> 
>> +	if ((id < 0) || (id >= RMNET_MAX_VND) || !rmnet_devices[id])
> 
> Unneeded inner "()"s. I see you have it on multiple places.
> 
>> +
>> +	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
> 
> The typecast is not needed since netdev_priv is void*. You have it all
> over the code.
> 
>> +#define ETH_P_MAP	0xDA1A		/* Multiplexing and Aggregation Protocol
>> +					 *  NOT AN OFFICIALLY REGISTERED ID ]
> 
> Please push this and ARPHRD_RAWIP as separate patches, to increase the
> visibility.
> 
>> +enum {
>> +	IFLA_RMNET_UNSPEC,
>> +	IFLA_RMNET_MUX_ID,
>> +	__IFLA_RMNET_MAX,
>> +};
> 
> This belongs to include/uapi/linux/if_link.h
> Please see IFLA_BOND_* as example
>> +#define RMNET_INIT_OK     0
>> +#define RMNET_INIT_ERROR  1
> 
> Please use common error codes (0/-ENOMEM/-EINVAL/...)
> 
>> +	static u32 rmnet_mod_mask = X
> 
> Don't use this custom helpers. Use existing loggign facilities.
> 
>> +			pr_notice("[RMNET:LOW] %s(): " fmt "\n", __func__, \
>> +				##__VA_ARGS__); \
>> +			} while (0)
> 
> These look scarry. Please use netdev_err, dev_err and others instead.
> 
>> +unsigned int rmnet_log_module_mask;
>> +module_param(rmnet_log_module_mask, uint, 0644);
>> +MODULE_PARM_DESC(rmnet_log_module_mask, "Logging module mask");
> 
> No module options please.
> 
>> +	config = (struct rmnet_phys_ep_conf_s *)
>> +		rcu_dereference(skb->dev->rx_handler_data);
> 
> This is certainly a misuse of dev->rx_handler_data. Dev private of a
> function arg to carry the pointer around.
> 
>> +struct net_device *rmnet_devices[RMNET_MAX_VND];
> 
> Avoid this global variable.
> 

Hi Jiri

I'll make these changes.

>> +	if (!data[IFLA_RMNET_MUX_ID])
>> +		return -EINVAL;
>> +
>> +	mux_id = nla_get_u16(data[IFLA_VLAN_ID]);
> 
> This is a bug I believe...             ^^^^^^^
> I'm pretty sure that you did not test this code.
> 

Since both IFLA_VLAN_ID and IFLA_RMNET_MUX_ID are 1 from enum, this 
actually
works. I was using VLAN as a reference, so I missed to change this to
IFLA_RMNET_MUX_ID.

> 
>> +				rmnet_kfree_skb
>> +				(skb,
>> +				 RMNET_STATS_SKBFREE_INGRESS_NOT_EXPECT_MAPD);
> 
> very odd formatting. Please fix.
> 
Checkpatch complains if it is over 80 chars in a line, so I had to do 
this.
I'll change to a single line.
