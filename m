From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: mdb: add vlan support for user entries
Date: Mon, 20 Jul 2015 15:28:17 -0700
Message-ID: <20150720152817.4c2f5c73@urahara>
References: <1436540528-42334-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36416 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600AbbGTW2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 18:28:07 -0400
Received: by pdjr16 with SMTP id r16so110060798pdj.3
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 15:28:07 -0700 (PDT)
In-Reply-To: <1436540528-42334-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jul 2015 08:02:08 -0700
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> index eaaea6208b42..3635b7797508 100644
> --- a/include/uapi/linux/if_bridge.h
> +++ b/include/uapi/linux/if_bridge.h
> @@ -182,6 +182,7 @@ struct br_mdb_entry {
>  #define MDB_TEMPORARY 0
>  #define MDB_PERMANENT 1
>  	__u8 state;
> +	__u16 vid;
>  	struct {
>  		union {
>  			__be32	ip4;

You added a new field into an unused hole in a data
structure shared as part of API with user space.

This seems like it might break when newer iproute
is run on older kernels. The vid would always be 0
on show and ignored when adding entries.
