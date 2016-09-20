From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v3] iproute2: build nsid-name cache only for commands that
 need it
Date: Tue, 20 Sep 2016 14:52:32 +0200
Message-ID: <fab03a54-57fe-1f72-2cfe-b395a82563e3@6wind.com>
References: <20160920060123.GA17211@toys.tundra.dog-lvm.novalocal>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: vadim4j@gmail.com
To: Anton Aksola <aakso@iki.fi>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35657 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbcITMwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 08:52:35 -0400
Received: by mail-wm0-f49.google.com with SMTP id l132so207639871wmf.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 05:52:34 -0700 (PDT)
In-Reply-To: <20160920060123.GA17211@toys.tundra.dog-lvm.novalocal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/09/2016 à 08:01, Anton Aksola a écrit :
> The calling of netns_map_init() before command parsing introduced
> a performance issue with large number of namespaces.
> 
> As commands such as add, del and exec do not need to iterate through
> /var/run/netns it would be good not no build the cache before executing
> these commands.
> 
> Example:
> unpatched:
> time seq 1 1000 | xargs -n 1 ip netns add
> 
> real    0m16.832s
> user    0m1.350s
> sys    0m15.029s
> 
> patched:
> time seq 1 1000 | xargs -n 1 ip netns add
> 
> real    0m3.859s
> user    0m0.132s
> sys    0m3.205s
> 
> Signed-off-by: Anton Aksola <aakso@iki.fi>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
