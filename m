From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ip6_gre: don't allow to remove the fb_tunnel_dev
Date: Tue, 15 Apr 2014 09:57:28 +0200
Message-ID: <534CE668.9060509@6wind.com>
References: <1397488298-19931-1-git-send-email-nicolas.dichtel@6wind.com> <20140415.000404.2110427476393772943.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:63913 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaDOH5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 03:57:31 -0400
Received: by mail-we0-f178.google.com with SMTP id u56so9176586wes.9
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 00:57:30 -0700 (PDT)
In-Reply-To: <20140415.000404.2110427476393772943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2014 06:04, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Mon, 14 Apr 2014 17:11:38 +0200
>
>> It's possible to remove the FB tunnel with the command 'ip link del =
ip6gre0' but
>> this is unsafe, the module always supposes that this device exists. =
=46or example,
>> ip6gre_tunnel_lookup() may use it unconditionally.
>>
>> Let's add a rtnl handler for dellink, which will never remove the FB=
 tunnel (we
>> let ip6gre_destroy_tunnels() do the job).
>>
>> Introduced by commit c12b395a4664 ("gre: Support GRE over IPv6").
>>
>> CC: Dmitry Kozlov <xeb@mail.ru>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> I don't see how we ever get rid of fb_tunnel_dev and can therefore
> remove the module successfully.
>
> It is created by the per-netns initialization, but since it isn't
> added to the hashes I don't see how the per-netns exit code can
> end up unregistering and freeing it up.
>
> How is this supposed to work?
It is added to the hashes in ip6gre_init_net() in bucket [0][0]:
#define tunnels_wc      tunnels[0]
[snip]
         rcu_assign_pointer(ign->tunnels_wc[0],
                            netdev_priv(ign->fb_tunnel_dev));

Thus the tunnel is deleted by the loop in ip6gre_destroy_tunnels().
