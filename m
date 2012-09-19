From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCHv2 bridge 5/7] bridge: Add vlan support to static neighbors
Date: Wed, 19 Sep 2012 08:20:27 -0700
Message-ID: <5059E2BB.8060507@intel.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com> <1348058536-22607-6-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61302 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983Ab2ISPUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 11:20:50 -0400
In-Reply-To: <1348058536-22607-6-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/19/2012 5:42 AM, Vlad Yasevich wrote:
> ---
>   include/linux/neighbour.h |    2 +-
>   net/bridge/br_fdb.c       |   12 ++++++------
>   2 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
> index 275e5d6..044df8f 100644
> --- a/include/linux/neighbour.h
> +++ b/include/linux/neighbour.h
> @@ -7,7 +7,7 @@
>   struct ndmsg {
>   	__u8		ndm_family;
>   	__u8		ndm_pad1;
> -	__u16		ndm_pad2;
> +	__u16		ndm_vlan;

But ndm_pad2 is also used in neighbour.c so you'll need to fix that up
as well.

net/core/neighbour.c: In function =E2neigh_fill_info=E2:
net/core/neighbour.c:2152: error: =E2struct ndmsg=E2 has no member name=
d=20
=E2ndm_pad2=E2
net/core/neighbour.c: In function =E2pneigh_fill_info=E2:
net/core/neighbour.c:2203: error: =E2struct ndmsg=E2 has no member name=
d=20
=E2ndm_pad2=E2
make[2]: *** [net/core/neighbour.o] Error 1
make[1]: *** [net/core] Error 2
make[1]: *** Waiting for unfinished jobs....
make: *** [net] Error 2
make: *** Waiting for unfinished jobs....
