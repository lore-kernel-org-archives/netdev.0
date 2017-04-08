From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Sat, 8 Apr 2017 16:14:39 -0400
Message-ID: <647a29e0-fd0d-9bba-e38f-e73dc35ae414@cumulusnetworks.com>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
 <20170408174900.12820-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36522 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdDHUOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 16:14:43 -0400
Received: by mail-pg0-f49.google.com with SMTP id g2so86593050pge.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 13:14:43 -0700 (PDT)
In-Reply-To: <20170408174900.12820-2-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/17 1:48 PM, Johannes Berg wrote:
> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
> index f3946a27bd07..d1564557d645 100644
> --- a/include/uapi/linux/netlink.h
> +++ b/include/uapi/linux/netlink.h
> @@ -101,6 +101,29 @@ struct nlmsghdr {
>  struct nlmsgerr {
>  	int		error;
>  	struct nlmsghdr msg;
> +	/*
> +	 * followed by the message contents unless NETLINK_CAP_ACK was set,
> +	 * message length is aligned with NLMSG_ALIGN()
> +	 */
> +	/*
> +	 * followed by TLVs defined in enum nlmsgerr_attrs
> +	 * if NETLINK_EXT_ACK was set
> +	 */
> +};
> +
> +/**
> + * enum nlmsgerr_attrs - netlink error message attributes
> + * @NLMSGERR_ATTR_UNUSED: unused
> + * @NLMSGERR_ATTR_MSG: error message string (string)
> + * @NLMSGERR_ATTR_OFFS: error offset in the original message (u32)
> + * @NLMSGERR_ATTR_ATTR: top-level attribute that caused the error
> + *	(or is missing, u16)
> + */
> +enum nlmsgerr_attrs {
> +	NLMSGERR_ATTR_UNUSED,
> +	NLMSGERR_ATTR_MSG,
> +	NLMSGERR_ATTR_OFFS,
> +	NLMSGERR_ATTR_ATTR,


can you add __NLMSGERR_ATTR_MAX and
#define NLMSGERR_ATTR_MAX (__NLMSGERR_ATTR_MAX - 1)
