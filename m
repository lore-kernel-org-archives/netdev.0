From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Mon, 16 Feb 2015 13:38:43 +0800
Message-ID: <54E18263.8040002@gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>  <1423815405-32644-4-git-send-email-fan.du@intel.com> <1423830709.4942.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:47096 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbBPFnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 00:43:19 -0500
Received: by mail-pa0-f54.google.com with SMTP id kx10so32803111pab.13
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 21:43:18 -0800 (PST)
In-Reply-To: <1423830709.4942.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8813=E6=97=A5 20:31, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Fri, 2015-02-13 at 16:16 +0800, Fan Du wrote:
>> >As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
>> >be armed once probing has converged. Once this timer expired,
>> >probing again to take advantage of any path PMTU change. The
>> >recommended probing interval is 10 minutes per RFC1981.
>> >
>> >Signed-off-by: Fan Du<fan.du@intel.com>
>> >---
>> >  include/net/inet_connection_sock.h |    2 ++
>> >  include/net/netns/ipv4.h           |    1 +
>> >  include/net/tcp.h                  |    3 +++
>> >  net/ipv4/sysctl_net_ipv4.c         |    7 +++++++
>> >  net/ipv4/tcp.c                     |    2 ++
>> >  net/ipv4/tcp_ipv4.c                |    1 +
>> >  net/ipv4/tcp_output.c              |   23 ++++++++++++++++++++++-
>> >  7 files changed, 38 insertions(+), 1 deletions(-)
>> >
>> >diff --git a/include/net/inet_connection_sock.h b/include/net/inet_=
connection_sock.h
>> >index 3d0932e..e78e5ab 100644
>> >--- a/include/net/inet_connection_sock.h
>> >+++ b/include/net/inet_connection_sock.h
>> >@@ -126,6 +126,8 @@ struct inet_connection_sock {
>> >
>> >  		int		  search_high_sav;
>> >  		int		  search_low_sav;
>> >+
>> >+		struct timer_list probe_timer;
>> >
> We certainly wont add yet another timer in tcp socket for such usage.
>
> And a buggy one, since you forgot all the refcounting associated with
> such timers.

oh, embarrassing...
Will place probe timer aside with icsk_delack_timer in struct inet_conn=
ection_sock,
and manipulate through sk_reset_timer.

Thanks for the reviewing.
