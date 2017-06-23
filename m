From: Gal Pressman <galp@mellanox.com>
Subject: Re: [RFC PATCH net-next 3/3] net/mlx5e: Expose link down reason to
 ethtool
Date: Fri, 23 Jun 2017 11:52:43 +0300
Message-ID: <d812f75d-9ef1-99e0-527a-7a15be9a47a7@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-4-git-send-email-galp@mellanox.com>
 <20170621213353.318e5d37@cakuba.netronome.com>
 <311af079-cf95-b487-f59a-9566e17296bf@gmail.com>
 <20170622153800.67f9635f@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Gal Pressman <galp@mellanox.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0047.outbound.protection.outlook.com ([104.47.1.47]:8364
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753759AbdFWIw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:52:57 -0400
In-Reply-To: <20170622153800.67f9635f@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Thu, 22 Jun 2017 11:33:39 +0300, Gal Pressman wrote:
>>> Is my reading correct that in case the reason is not in the
>>> pddr2ethtool_table opaque binary data will be passed from the firmware
>>> to user space?  Is there any particular reason to allow for this?  If
>>> it's just for the rare scenario where a new error code needs to be
>>> added perhaps it would be enough to dump the FW-provided message to the
>>> logs?  
>> No binary data is passed in this patch, the monitor_opcode is simply a vendor specific
>> 16 bit id that is used when the reason  is not generic enough to have it's own enum.
> Sorry if I'm wrong, I thought this would potentially copy
> ETH_GSTRING_LEN bytes to userspace:
>
> +	if (status_message)
> +		memcpy(status_message,
> +		       MLX5_ADDR_OF(pddr_reg, out, page_data.troubleshooting_info_page.status_message),
> +		       ETH_GSTRING_LEN);
>
> I'm also still not sure why a reason would not be generic enough for
> the enum, if it fits in the 16bit vendor enum... 
Some reasons might be very specific, and only relevant to my hardware for example.
In that case I'd like to avoid an enum entry that is not wide enough to be used by anyone else but me,
and still have a way to pass it to the user.

The userspace patches will allow for a vendor parser (similar to ethtool regdump parsers) that can
convert this 16bit id to a string.
