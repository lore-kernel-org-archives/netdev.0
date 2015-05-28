From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 01/14] ethtool: Add helper routines to pass vf to rx_flow_spec
Date: Thu, 28 May 2015 17:20:05 +0300
Message-ID: <55672415.4070300@cogentembedded.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com> <1432812339-17129-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Alex Duyck <alexander.h.duyck@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33331 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbbE1OUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 10:20:09 -0400
Received: by labpy14 with SMTP id py14so21278717lab.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 07:20:07 -0700 (PDT)
In-Reply-To: <1432812339-17129-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/28/2015 2:25 PM, Jeff Kirsher wrote:

> From: John Fastabend <john.r.fastabend@intel.com>

> The ring_cookie is 64 bits wide which is much larger than can be used
> for actual queue index values. So provide some helper routines to
> pack a VF index into the cookie. This is useful to steer packets to
> a VF ring without having to know the queue layout of the device.

> CC: Alex Duyck <alexander.h.duyck@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   include/uapi/linux/ethtool.h | 25 +++++++++++++++++++++++++
>   1 file changed, 25 insertions(+)

> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index ae832b4..0594933 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -796,6 +796,31 @@ struct ethtool_rx_flow_spec {
>   	__u32		location;
>   };
>
> +/* How rings are layed out when accessing virtual functions or

    s/layed/laid/.

> + * offloaded queues is device specific. To allow users to do flow
> + * steering and specify these queues the ring cookie is partitioned
> + * into a 32bit queue index with an 8 bit virtual function id.
> + * This also leaves the 3bytes for further specifiers. It is possible
> + * future devices may support more than 256 virtual functions if
> + * devices start supporting PCIe w/ARI. However at the moment I
> + * do not know of any devices that support this so I do not reserve
> + * space for this at this time. If a future patch consumes the next
> + * byte it should be aware of this possiblity.

    Possibility.

[...]

WBR, Sergei
