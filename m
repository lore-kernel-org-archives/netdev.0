From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: make net.core.{r,w}mem_{default,max} namespaced
Date: Mon, 31 Jul 2017 03:07:32 -0700
Message-ID: <1501495652.1876.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170726170333.24580-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matteo Croce <mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35301 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdGaKHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 06:07:35 -0400
Received: by mail-wm0-f65.google.com with SMTP id r77so21851173wmd.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 03:07:34 -0700 (PDT)
In-Reply-To: <20170726170333.24580-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-07-26 at 19:03 +0200, Matteo Croce wrote:
> The following sysctl are global and can't be read or set from a netns:
> 
> net.core.rmem_default
> net.core.rmem_max
> net.core.wmem_default
> net.core.wmem_max
> 
> Make the following sysctl parameters available from within a network
> namespace, allowing to set unique values per network namespace.
> 
> My concern is about the initial value of this sysctl in the newly
> creates netns: I'm not sure if is better to copy them from the init
> namespace or set them to the default values.
> 
> Setting them to the default value has the advantage that a new namespace
> behaves like a freshly booted system, while copying them from the init
> netns has the advantage of keeping the current behaviour as the values
> from the init netns are used.
> 
> Signed-off-by: Matteo Croce <mcroce@redhat.com>
> ---

It looks that these sysctls were giving some kind of isolation.

If we make them per namespace, a malicious usage could eat all memory
and hurt other namespaces.
