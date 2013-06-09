From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [Patch net-next] ipv6: add missing /proc/sys/net/ipv6/ping_group_range
Date: Sun, 9 Jun 2013 18:42:20 +0900
Message-ID: <CAKD1Yr1JcL22bSGyvNQrUj4iPNxH3NS+re7jXeBEuvCTJf-Hjw@mail.gmail.com>
References: <1370685275-22059-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:34709 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab3FIJml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 05:42:41 -0400
Received: by mail-qa0-f42.google.com with SMTP id hu16so1807016qab.15
        for <netdev@vger.kernel.org>; Sun, 09 Jun 2013 02:42:40 -0700 (PDT)
In-Reply-To: <1370685275-22059-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 8, 2013 at 6:54 PM, Cong Wang <amwang@redhat.com> wrote:
> commit 6d0bfe22611602f366 (net: ipv6: Add IPv6 support to the ping socket.)
> adds IPv6 ping socket support, but forgot to create
> /proc/sys/net/ipv6/ping_group_range, therefore it wrongly shares
> /proc/sys/net/ipv4/ping_group_range with IPv4.

As you said, I'm not sure that sharing the sysctl file with IPv4 is a
problem. Is it useful to support different permissions for IPv4 ping
versus IPv6 ping? I would imagine that if an admin wants certain
groups to be able to run ping, those groups would be the same for IPv4
ping and IPv6 ping. But I'm not the authority here. Maybe David has an
opinion?

That said - if we do want to do this, I think you should find a way to
do it with less code duplication. For example, your newly-added
ping_v6_init_sock is almost line-for-line identical with the current
ping_init_sock. This adds maintenance burden, because any future fix
needs to modify both functions, and creates the opportunity for the
two functions to diverge in the future, leading to different behaviour
and/or bugs in the future. It should be trivial to refactor the common
code out into one function that is called by both the IPv4 and the
IPv6 init functions.

There is similar code duplication in your new get_ping_group range and
in other places as well.
