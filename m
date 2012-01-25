From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH net] caif: Fix crash due to uninitialized net name-space.
Date: Wed, 25 Jan 2012 11:13:52 -0500
Message-ID: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
References: <CA+1xoqdZapYjS4gPf_uGwEdFQQdZ525mASr7iFKPXJdCBdRLKA@mail.gmail.com>
 <1327444045-1033-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	davej@redhat.com, sjurbren@gmail.com, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327444045-1033-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2012 at 5:27 PM, Sjur Br=E6ndeland
<sjur.brandeland@stericsson.com> wrote:
> net_generic() calls BUG_ON() if called with uninitialized
> network name-space. Add check if net is initialized before
> calling net_generic(). This fixes the following oops:
>
> [ =A0200.752016] kernel BUG at include/net/netns/generic.h:40!
> ...
> [ =A0200.752016] =A0[<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
> [ =A0200.752016] =A0[<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/=
0x20
> [ =A0200.752016] =A0[<ffffffff825c41be>] caif_device_notify+0x2e/0x53=
0
> [ =A0200.752016] =A0[<ffffffff810d61b7>] notifier_call_chain+0x67/0x1=
10
> [ =A0200.752016] =A0[<ffffffff810d67c1>] raw_notifier_call_chain+0x11=
/0x20
> [ =A0200.752016] =A0[<ffffffff821bae82>] call_netdevice_notifiers+0x3=
2/0x60
> [ =A0200.752016] =A0[<ffffffff821c2b26>] register_netdevice+0x196/0x3=
00
> [ =A0200.752016] =A0[<ffffffff821c2ca9>] register_netdev+0x19/0x30
> [ =A0200.752016] =A0[<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
> [ =A0200.752016] =A0[<ffffffff821b5e62>] ops_init+0x42/0x180
> [ =A0200.752016] =A0[<ffffffff821b600b>] setup_net+0x6b/0x100
> [ =A0200.752016] =A0[<ffffffff821b6466>] copy_net_ns+0x86/0x110
> [ =A0200.752016] =A0[<ffffffff810d5789>] create_new_namespaces+0xd9/0=
x190
>
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> ---
>
> Hi Sasha,
>
> Do you have any chance to review and test this patch?
> I'd like to get the net namespace handling this right this time ...
>
> Thanks,
> Sjur

Works for me.

Tested-by: Sasha Levin <levinsasha928@gmail.com>
