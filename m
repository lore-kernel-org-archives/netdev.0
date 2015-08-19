From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH ipsec-next] xfrm: Use VRF master index if output device is enslaved
Date: Wed, 19 Aug 2015 15:47:18 +0300
Message-ID: <0723F8F1-7349-45FF-BE9C-D2667DA28E0A@cumulusnetworks.com>
References: <1439913296-6026-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38432 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbbHSMrW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 08:47:22 -0400
Received: by wicja10 with SMTP id ja10so7324638wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 05:47:21 -0700 (PDT)
In-Reply-To: <1439913296-6026-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 18, 2015, at 6:54 PM, David Ahern <dsa@cumulusnetworks.com> wr=
ote:
>=20
> Directs route lookups to VRF table. Compiles out if NET_VRF is not
> enabled. With this patch able to successfully bring up ipsec tunnels
> in VRFs, even with duplicate network configuration (IPv4 tested).
>=20
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> net/ipv4/xfrm4_policy.c | 7 +++++--
> net/ipv6/xfrm6_policy.c | 7 +++++--
> 2 files changed, 10 insertions(+), 4 deletions(-)

I think you should use the new vrf_master_index() helper that acquires =
rcu because
it looks possible to call ->decode_session() without rcu read lock, e.g=
=2E in the hold_timer
function xfrm_policy_queue_process(), though I haven=E2=80=99t tested i=
t and might be missing
something. :-)

Cheers,
 Nik