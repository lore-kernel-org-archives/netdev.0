From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Fri, 15 Jan 2010 08:02:26 +0100
Message-ID: <m2ockvhmv1.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Samir Bellabes wrote:
>> +/**
>> + * snet_nl_register - Handle a REGISTER message
>> + * @skb: the NETLINK buffer
>> + * @info: the Generic NETLINK info block
>> + *
>> + * Description:
>> + * Notify the kernel that an application is listening for events.
>> + * Returns zero on success, negative values on failure.
>> + */
>> +static int snet_nl_register(struct sk_buff *skb, struct genl_info *info)
>> +{
>> +	int ret = -EINVAL;
>> +	u32 version = 0;
>> +	u8 set_resp_flag = 0;
>> +
>> +	atomic_set(&snet_nl_seq, info->snd_seq);
>> +
>> +	if (!info->attrs[SNET_A_VERSION])
>> +		return -EINVAL;
>> +	version = nla_get_u32(info->attrs[SNET_A_VERSION]);
>> +
>> +	if (version == SNET_VERSION) {	/* version is compliant */
>> +		atomic_inc(&snet_num_listeners);
>> +		set_resp_flag = 1;
>> +	}
>> +
>> +	ret = snet_nl_response_flag(info, &snet_genl_family,
>> +				    SNET_C_REGISTER, SNET_A_REGISTERED,
>> +				    set_resp_flag);
>
> Is this really needed? A return value of 0 should already tell userspace
> that the command was successful. If it really wants a seperate success
> message, it can use NLM_F_ACK. This will also automatically take care
> of using the proper sequence number, so the snet_nl_seq handling isn't
> required anymore. Same for all similar cases below.

Indeed, we can use the return value to inform the userspace about the
status of operations. I moved all the code, and deleted the no longer
used function snet_nl_response_flag()

Thanks Patrick,
sam
