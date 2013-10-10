From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: fix vport-netdev unregister
Date: Wed, 9 Oct 2013 18:24:08 -0700
Message-ID: <CAEP_g=8sNfsXTiJHcRoG1Nz9OpqjQEbffaKcytZv0oZc=ig-Aw@mail.gmail.com>
References: <1381288051-3607-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:44854 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751881Ab3JJBYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 21:24:31 -0400
Received: by mail-la0-f47.google.com with SMTP id eo20so1423318lab.20
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 18:24:28 -0700 (PDT)
In-Reply-To: <1381288051-3607-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 8, 2013 at 8:07 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> The combination of two commits
>
> commit 8e4e1713e4
> ("openvswitch: Simplify datapath locking.")
>
> and
>
> commit 2537b4dd0a
> ("openvswitch:: link upper device for port devices")
>
> introduced a bug where upper_dev wasn't unlinked upon
> netdev_unregister notification
>
> The following steps:
>
>   modprobe openvswitch
>   ovs-dpctl add-dp test
>   ip tuntap add dev tap1 mode tap
>   ovs-dpctl add-if test tap1
>   ip tuntap del dev tap1 mode tap
>
> are causing multiple warnings:

[...]

Hmm, you are right. Pravin mentioned some concerns about layering with
this patch so I believe he's trying to think of a way to minimize
that.
