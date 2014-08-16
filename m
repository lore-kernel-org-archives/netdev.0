From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] vxlan: fix incorrect initializer in union vxlan_addr
Date: Sat, 16 Aug 2014 15:48:06 -0700
Message-ID: <CAHA+R7M1DwPgLMYaSMEiU2eXZFqYYL03CJODhmuUrOthpeotzw@mail.gmail.com>
References: <53EDCC19.70702@linux.vnet.ibm.com>
	<53EDCCFE.5090301@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Gerhard Stenzel <gstenzel@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33357 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbaHPWsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 18:48:08 -0400
Received: by mail-lb0-f179.google.com with SMTP id v6so3006339lbi.10
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2014 15:48:06 -0700 (PDT)
In-Reply-To: <53EDCCFE.5090301@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2014 at 2:03 AM, Gerhard Stenzel
<gstenzel@linux.vnet.ibm.com> wrote:
>
> The first initializer in the following
>
>                 union vxlan_addr ipa = {
>                         .sin.sin_addr.s_addr = tip,
>                         .sa.sa_family = AF_INET,
>                 };
>
> is optimised away by the compiler, due to the second initializer,
> therefore initialising .sin.sin_addr.s_addr always to 0.
> This results in netlink messages indicating a L3 miss never contain the
> missed IP address. This was observed with GCC 4.8 and 4.9. I do not know
> about previous versions.
> The problem affects user space programs relying on an IP address being
> sent as part of a netlink message indicating a L3 miss.
>
> Changing
>                         .sa.sa_family = AF_INET,
> to
>                         .sin.sin_family = AF_INET,
> fixes the problem.

So GCC can't figure out we are initializing different parts of this
union through
different members... Or maybe we should not use initializer at all.

Anyway,

Acked-by: Cong Wang <cwang@twopensource.com>
