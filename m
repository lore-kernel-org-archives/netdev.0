From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: ipvs oops in 3.0-rc7
Date: Thu, 21 Jul 2011 16:42:17 +0800
Message-ID: <CA+v9cxYJtrpUSHWY5Z2R14kZjX1c5nd2yYrvTx2URLJz26d_Tw@mail.gmail.com>
References: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
	<20110721054033.GA8299@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	huajun li <huajun.li.lee@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:39843 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab1GUImT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 04:42:19 -0400
In-Reply-To: <20110721054033.GA8299@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Randy and Simon,
    I happened to meet the issue too, loading and unloading module of
ip_vs, then loading it again will cause Oops, the root cause may be
ip_vs_dst_notifier is not unregistered. Please try following patch, it
works for me.


Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
index 699c79a..a178cb3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3771,6 +3771,7 @@ err_sock:
 void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
+	unregister_netdevice_notifier(&ip_vs_dst_notifier);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
 	LeaveFunction(2);
--=20
1.7.4.1


2011/7/21 Simon Horman <horms@verge.net.au>:
> On Wed, Jul 20, 2011 at 08:50:19PM -0700, Randy Dunlap wrote:
>> I'm seeing the following Oops in 3.0-rc7 on x86_64, just loading and=
 unloading
>> modules. =A0Any chance this is already fixed? =A0I can test current =
git, but I
>> wanted to ask first.
>>
>> Looks like it is on the second module load of ip_vs (i.e.,
>> modprobe ip_vs; rmmod ip_vs; modprobe ip_vs).
>
> Hi Randy,
>
> I don't believe that this problem has been resolved (or observed befo=
re).
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
