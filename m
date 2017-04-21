From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: Disable notification for
 NETDEV_NAMECHANGE event
Date: Fri, 21 Apr 2017 12:08:52 -0600
Message-ID: <becfb3d4-5e9d-800b-fc67-1e99f4b14db9@cumulusnetworks.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35604 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1042011AbdDUSfR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:35:17 -0400
Received: by mail-io0-f179.google.com with SMTP id r16so124399216ioi.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:35:12 -0700 (PDT)
In-Reply-To: <1492795881-11914-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/17 11:31 AM, Vladislav Yasevich wrote:
> The data signaling name change is already provided at
> the end of do_setlink().  This event handler just generates
> a duplicate announcement.  Disable it.
> 
> CC: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  net/core/rtnetlink.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 0ee5479..e8e6816 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -4123,7 +4123,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  
>  	switch (event) {
>  	case NETDEV_REBOOT:
> -	case NETDEV_CHANGENAME:
>  	case NETDEV_FEAT_CHANGE:
>  	case NETDEV_BONDING_FAILOVER:
>  	case NETDEV_NOTIFY_PEERS:
> 


I only see one using the ip monitor.

$ ip li set foobar name fubar

generates these 3 messages:

[LINK]12: fubar: <BROADCAST,NOARP> mtu 1500 qdisc noqueue state DOWN
group default
    link/ether 76:cd:72:dd:2a:cb brd ff:ff:ff:ff:ff:ff
Unknown message: type=0x00000051(81) flags=0x00000000(0)len=0x0000001c(28)
[NETCONF]ipv4 dev dummy2 forwarding on rp_filter off mc_forwarding off
proxy_neigh off ignore_routes_with_linkdown off
Unknown message: type=0x00000051(81) flags=0x00000000(0)len=0x0000001c(28)
[NETCONF]ipv6 dev dummy2 forwarding on mc_forwarding off proxy_neigh off
ignore_routes_with_linkdown off

do_setlink only sets DO_SETLINK_MODIFIED so a name change alone will not
generate 2 messages.
