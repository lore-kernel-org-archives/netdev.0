From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v2 04/12] net: flow_table: create a set of common
 headers and actions
Date: Sat, 17 Jan 2015 22:34:35 -0800
Message-ID: <CAE4R7bAG8-WE0dw0S27_kMUXpvvNjNqii4bT+JvEpg7h3+SRHQ@mail.gmail.com>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
	<20150113213645.13874.24934.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Netdev <netdev@vger.kernel.org>, gerlitz.or@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:65406 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbbARGeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 01:34:37 -0500
Received: by mail-we0-f180.google.com with SMTP id m14so1099986wev.11
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 22:34:36 -0800 (PST)
In-Reply-To: <20150113213645.13874.24934.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 1:36 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> This adds common headers and actions that drivers can use.
>
> I have not yet moved the header graphs into the common header
> because I'm not entirely convinced its re-usable. The devices
> I have been looking at have different enough header graphs that
> they wouldn't be re-usable. However possibly many 40Gbp NICs
> for example could share a common header graph. When we get
> multiple implementations we can move this into the common file
> if it makes sense.
>
> And table structures seem to be unique enough that there is
> little value in putting each devices table layout into the
> common file so its left for device specific implementation.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/linux/if_flow_common.h |  257 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 257 insertions(+)
>  create mode 100644 include/linux/if_flow_common.h
>
> diff --git a/include/linux/if_flow_common.h b/include/linux/if_flow_common.h
> new file mode 100644
> index 0000000..d4dd749
> --- /dev/null
> +++ b/include/linux/if_flow_common.h
> @@ -0,0 +1,257 @@
> +#ifndef _IF_FLOW_COMMON_H_
> +#define _IF_FLOW_COMMON_H_
> +
> +#include <linux/if_flow.h>
> +
> +/* Common header definition this section provides a set of common or
> + * standard headers that device driver writers may use to simplify the
> + * driver creation. We do not want vendor or driver specific headers
> + * here though. Driver authors can keep these contained to their driver
> + *
> + * Driver authors may use unique IDs greater than HEADER_MAX_UID it is
> + * guaranteed to be larger than any unique IDs used here.
> + */
> +#define HEADER_MAX_UID 100
> +
> +enum net_flow_headers {
> +       HEADER_UNSPEC,
> +       HEADER_ETHERNET,
> +       HEADER_VLAN,
> +       HEADER_IPV4,
> +};
> +
> +enum net_flow_ethernet_fields_ids {
> +       HEADER_ETHERNET_UNSPEC,
> +       HEADER_ETHERNET_SRC_MAC,
> +       HEADER_ETHERNET_DST_MAC,
> +       HEADER_ETHERNET_ETHERTYPE,
> +};
> +
> +struct net_flow_field net_flow_ethernet_fields[] = {
> +       { .name = "src_mac", .uid = HEADER_ETHERNET_SRC_MAC, .bitwidth = 48},
> +       { .name = "dst_mac", .uid = HEADER_ETHERNET_DST_MAC, .bitwidth = 48},
> +       { .name = "ethertype",
> +         .uid = HEADER_ETHERNET_ETHERTYPE,
> +         .bitwidth = 16},
> +};

All of these code chunks get repeated in each module that includes
if_flow_common.h, regardless if the module needs all of them.

Maybe #define would be better?

> +struct net_flow_field net_flow_ipv4_fields[14] = {

net_flow_ipv4_fields[].  more like this...

-scott
