From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Sun, 22 May 2011 21:46:32 +0400
Message-ID: <20110522174632.GA4388@albatros>
References: <BANLkTinh0cmb0hzpVdm5XemT5NeULeAoHQ@mail.gmail.com>
 <20110522174412.2F0C.0@paddy.troja.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Solar Designer <solar@openwall.com>
To: Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56399 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab1EVRqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 13:46:40 -0400
Received: by bwz15 with SMTP id 15so4165400bwz.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 10:46:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110522174412.2F0C.0@paddy.troja.mff.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2011 at 18:01 +0200, Pavel Kankovsky wrote:
> On Thu, 14 Apr 2011, Alexey Dobriyan wrote:
> 
> > Also, there was big discussion re exposing kernel socket pointers,
> > which this file continue to do.
> 
> One late comment:
> 
> The code was intented to immitate /proc/net/udp.
> 
> As far as I can tell UDP and TCP (having checked udp.c and tcp_ipv[46].c
> in the latest net-next-2.6) do not have any qualms about exposing kernel
> pointers so we are a little bit holier than the pope here. :)

Anyway, ping uses %pK:

   seq_printf(f, "%5d: %08X:%04X %08X:%04X"
           " %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK d%n",
           bucket, src, srcp, dest, destp, sp->sk_state,
           sk_wmem_alloc_get(sp),
           sk_rmem_alloc_get(sp),
           0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
           atomic_read(&sp->sk_refcnt), sp,
           atomic_read(&sp->sk_drops), len);

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
