From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] ipconfig: send Client-identifier in DHCP requests
Date: Thu, 15 Oct 2015 07:56:52 -0700
Message-ID: <CAGVrzcaDXgpao7SjhRg3UE67gMSzD70vjQV2gXkF5=OZsxykfw@mail.gmail.com>
References: <1444899276-21228-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35291 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbJOO5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 10:57:32 -0400
Received: by igbkq10 with SMTP id kq10so137519932igb.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 07:57:32 -0700 (PDT)
In-Reply-To: <1444899276-21228-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-15 1:54 GMT-07:00  <roy.qing.li@gmail.com>:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> A dhcp server may provide parameters to a client from a pool of IP
> addresses and using a shared rootfs, or provide a specific set of
> parameters for a specific client, usually using the MAC address to
> identify each client individually. The dhcp protocol also specifies
> a client-id field which can be used to determine the correct
> parameters to supply when no MAC address is available. There is
> currently no way to tell the kernel to supply a specific client-id,
> only the userspace dhcp clients support this feature, but this can
> not be used when the network is needed before userspace is available
> such as when the root filesystem is on NFS.
>
> This patch is to be able to do something like "ip=dhcp,client_id_type,
> client_id_value", as a kernel parameter to enable the kernel to
> identify itself to the server.
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  Documentation/filesystems/nfs/nfsroot.txt |  3 +++
>  net/ipv4/ipconfig.c                       | 32 ++++++++++++++++++++++++++++++-
>  2 files changed, 34 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/filesystems/nfs/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
> index 2d66ed6..bb5ab6d 100644
> --- a/Documentation/filesystems/nfs/nfsroot.txt
> +++ b/Documentation/filesystems/nfs/nfsroot.txt
> @@ -157,6 +157,9 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:
>                   both:        use both BOOTP and RARP but not DHCP
>                                (old option kept for backwards compatibility)
>
> +               if dhcp is used, the client identifier can be used by following
> +               format "ip=dhcp,client-id-type,client-id-value"
> +
>                  Default: any
>
>    <dns0-ip>    IP address of first nameserver.
> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index ed4ef09..0bc7412 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> @@ -146,6 +146,10 @@ u8 root_server_path[256] = { 0, }; /* Path to mount as root */
>  /* vendor class identifier */
>  static char vendor_class_identifier[253] __initdata;
>
> +#if defined(CONFIG_IP_PNP_DHCP)
> +static char dhcp_client_identifier[253] __initdata;
> +#endif
> +
>  /* Persistent data: */
>
>  static int ic_proto_used;                      /* Protocol used, if any */
> @@ -728,6 +732,16 @@ ic_dhcp_init_options(u8 *options)
>                         memcpy(e, vendor_class_identifier, len);
>                         e += len;
>                 }
> +               len = strlen(dhcp_client_identifier + 1);

Did not you mean strlen(dhcp_client_identifer) + 1 instead?
-- 
Florian
