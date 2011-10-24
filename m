From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next V4] net: introduce ethernet teaming device
Date: Mon, 24 Oct 2011 19:22:36 +0200
Message-ID: <CAHXqBFLzuxaCW-q5X066zM3E_t9KHO1uTF6WD3Je2u0EifaSSw@mail.gmail.com>
References: <1319444005-1281-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fbl@redhat.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59639 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab1JXRW5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 13:22:57 -0400
Received: by yxl42 with SMTP id 42so3396256yxl.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 10:22:57 -0700 (PDT)
In-Reply-To: <1319444005-1281-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/24 Jiri Pirko <jpirko@redhat.com>:
> This patch introduces new network device called team. It supposes to =
be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.
[...]
> =A0drivers/net/team/team.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | 1573=
 +++++++++++++++++++++++++++++
> =A0drivers/net/team/team_mode_activebackup.c | =A0152 +++
> =A0drivers/net/team/team_mode_roundrobin.c =A0 | =A0107 ++

I think this mode-modularity is overkill. One mode will compile to at
most a few hundred bytes of code+data, but will use at least 10 times
that to get loaded and tracked properly. How often/how many more modes
you anticipate to be introduced? You could just keep the modular
design but drop the kernel module separation and maybe have modes
conditionally compiled (for those from the embedded world squeezing
every byte).

Best Regards,
Micha=B3 Miros=B3aw
