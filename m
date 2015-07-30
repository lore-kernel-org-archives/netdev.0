From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] bridge fdb: add 'use' option to set NTF_USE
 flag in fdb add requests
Date: Wed, 29 Jul 2015 17:50:20 -0700
Message-ID: <55B974CC.9070004@cumulusnetworks.com>
References: <1438205199-34880-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34011 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978AbbG3AuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 20:50:21 -0400
Received: by pacan13 with SMTP id an13so14104198pac.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 17:50:21 -0700 (PDT)
In-Reply-To: <1438205199-34880-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/15, 2:26 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This is similar to command options corresponding to other NTF_* flags
> already exposed to the user space (examples self/master).
>
> Also updates bridge man page (The man page patch also includes
> a fix to the 'self' entry and documents 'master' for fdb entries)
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
just realized i forgot to update usage()...will respin..

>   bridge/fdb.c      |    2 ++
>   man/man8/bridge.8 |   15 ++++++++++++---
>   2 files changed, 14 insertions(+), 3 deletions(-)
>
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index 278e55f..165fe59 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -305,6 +305,8 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
>   				duparg2("vlan", *argv);
>   			NEXT_ARG();
>   			vid = atoi(*argv);
> +		} else if (matches(*argv, "use") == 0) {
> +			req.ndm.ndm_flags |= NTF_USE;
>   		} else {
>   			if (strcmp(*argv, "to") == 0) {
>   				NEXT_ARG();
> diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
> index 4135d01..c86db03 100644
> --- a/man/man8/bridge.8
> +++ b/man/man8/bridge.8
> @@ -53,8 +53,8 @@ bridge \- show / manipulate bridge addresses and devices
>   .I LLADDR
>   .B  dev
>   .IR DEV " { "
> -.BR local " | " temp " } { "
> -.BR self " } { " router " } [ "
> +.BR local " | " temp " } [ "
> +.BR self " ] [ " master " ] [ " router " ] [ " use " ] [ "
>   .B  dst
>   .IR IPADDR " ] [ "
>   .B vni
> @@ -323,7 +323,11 @@ the Ethernet MAC address.
>   the interface to which this address is associated.
>   
>   .B self
> -- the address is associated with a software fdb (default)
> +- the address is associated with a hardware fdb
> +.sp
> +
> +.B master
> +- the address is associated with software fdb (default)
>   .sp
>   
>   .B router
> @@ -332,6 +336,11 @@ Valid if the referenced device is a VXLAN type device and has
>   route shortcircuit enabled.
>   .sp
>   
> +.B use
> +- the address is in use. User space can use this option to
> +indicate to the kernel that the fdb entry is in use.
> +.sp
> +
>   .in -8
>   The next command line parameters apply only
>   when the specified device
