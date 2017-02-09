From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net/devlink: Add E-Switch encapsulation
 control
Date: Thu, 9 Feb 2017 18:36:34 +0100
Message-ID: <20170209173634.GD2018@nanopsycho>
References: <1486657398-6298-1-git-send-email-ogerlitz@mellanox.com>
 <1486657398-6298-2-git-send-email-ogerlitz@mellanox.com>
 <20170209171053.GC2018@nanopsycho>
 <2ccce1b4-4407-fe66-847a-9159579fac27@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36077 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932089AbdBIRgh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:36:37 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so3939582wmd.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:36:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <2ccce1b4-4407-fe66-847a-9159579fac27@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 09, 2017 at 06:20:14PM CET, ogerlitz@mellanox.com wrote:
>On 2/9/2017 7:10 PM, Jiri Pirko wrote:
>> > @@ -1470,11 +1480,23 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
>> > 	const struct devlink_ops *ops = devlink->ops;
>> > 	u16 mode;
>> > 	u8 inline_mode;
>> > +	bool encap;
>> > 	int err = 0;
>> > 
>> > 	if (!ops)
>> > 		return -EOPNOTSUPP;
>> > 
>> > +	if (info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP]) {
>> > +		if (!ops->eswitch_encap_set)
>> > +			return -EOPNOTSUPP;
>> > +		if (!info->attrs[DEVLINK_ATTR_ESWITCH_MODE])

Why you need to check this? Should be possible to set the attrs
separatelly.


>> > +			return -EINVAL;
>> > +		encap = nla_get_u8(info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP]);
>> > +		err = ops->eswitch_encap_set(devlink, encap);
>> > +		if (err)
>> > +			return err;
>> > +	}
>> Please maintain the same order as the attr enum and getters and put this
>> behind the inline_mode.
>
>The HW driver might want to use the attributes only when they are called to
>change the eswitch mode.

I don't get it. Should be a separate attribute - separate op


>
>I see that the patch is not too consistent with setting the inline mode which
>is done after setting the eswitch mode, mmm, guess we need to fix that.
>
>Or.
>
>
>
