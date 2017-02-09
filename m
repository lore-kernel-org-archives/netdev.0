From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 9 Feb 2017 08:49:35 +0100
Message-ID: <20170209074935.GA2018@nanopsycho>
References: <20170208234127.3041579-1-tom@herbertland.com>
 <20170208234127.3041579-2-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34329 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdBIH6j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 02:58:39 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so1602999wmi.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 23:58:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170208234127.3041579-2-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 09, 2017 at 12:41:20AM CET, tom@herbertland.com wrote:
>This patch creates an infrastructure for registering and running code at
>XDP hooks in drivers. This extends and generalizes the original XDP/BPF
>interface. Specifically, it defines a generic xdp_hook structure and a
>set of hooks that can be assigned to devices or napi instances.  These
>hooks are also generic to allow for XDP/BPF programs as well as non-BPF
>code (e.g. kernel code can be written in a module).
>
>An XDP hook is defined by the xdp_hook structure. A pointer to this
>structure is passed into the XDP register function to set up a hook.
>The XDP register function mallocs its own xdp_hook structure and copies
>the values from the xdp_hook passed in. The register function also saves
>the pointer value of the xdp_hook argument; this pointer is used in
>subsequently calls to XDP to identify the registered hook.
>
>The interface is defined in net/xdp.h. This includes the definition of
>xdp_hook, functions to register and unregister hooks on a device
>or individual instances of napi, and xdp_hook_run that is called by
>drivers to run the hooks.
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>
>---
> drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c |   1 +
> include/linux/filter.h                           |  10 +-
> include/linux/netdev_features.h                  |   3 +-
> include/linux/netdevice.h                        |  16 ++
> include/net/xdp.h                                | 310 +++++++++++++++++++++++
> include/trace/events/xdp.h                       |  31 +++
> kernel/bpf/core.c                                |   1 +
> net/core/Makefile                                |   2 +-
> net/core/dev.c                                   |  53 ++--
> net/core/filter.c                                |   1 +
> net/core/rtnetlink.c                             |  14 +-
> net/core/xdp.c                                   | 304 ++++++++++++++++++++++
> 12 files changed, 711 insertions(+), 35 deletions(-)
> create mode 100644 include/net/xdp.h
> create mode 100644 net/core/xdp.c
>

[...]

>@@ -48,6 +49,36 @@ TRACE_EVENT(xdp_exception,
> 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
> );
> 
>+/* Temporaray trace function. This will be renamed to xdp_exception after all

typo

>+ * the calling drivers have been patched.
>+ */
