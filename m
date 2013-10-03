From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] dev: add support of flag IFF_NOPROC
Date: Thu, 3 Oct 2013 10:46:27 -0700
Message-ID: <20131003104627.411f5cc4@nehalam.linuxnetplumber.net>
References: <1380806905-4461-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:51676 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810Ab3JCRqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 13:46:31 -0400
Received: by mail-pa0-f47.google.com with SMTP id kp14so2959085pab.34
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 10:46:31 -0700 (PDT)
In-Reply-To: <1380806905-4461-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Oct 2013 15:28:25 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> This flag allows to create netdevices without creating directories in
> /proc, ie no /proc/sys/net/ipv[4|6]/[conf|neigh]/<dev> and no
> /proc/net/dev_snmp6/<dev>.
> 
> When a system creates a lot of virtual netdevices, this allows to speed up the
> creation time. For systems which continuously create and destroy virtual
> netdevices, proc entries for these netdevices may not be used, hence adding this
> flag is interesting.
> 
> Note that the flag should be specified at the creation time (before calling
> register_netdevice()) and cannot be removed during the life of the netdevice.
> 
> Here are some numbers:
> 
> dummy20000.batch contains 20 000 times 'link add type dummy' and
> dummy20000-noproc.batch 20 000 times 'link add noproc type dummy'.
> 
> time ip -b dummy20000.batch
> real    0m56.367s
> user    0m0.200s
> sys     0m53.070s
> 
> time ip -b dummy20000-noproc.batch
> real    0m42.417s
> user    0m0.310s
> sys     0m38.470s
> 
> Suggested-by: Thierry Herbelot <thierry.herbelot@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Seems like a special case. The problem is that you just created devices
that are unmanageable and might well break other tools in the system.
What about speeding up proc or sysfs? Or providing a bulk create/destroy.
Also if you used a custom program it could have seperate netlink send
and receive threads to pipeline the creation.
