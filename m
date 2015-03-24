From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH for kernel 3.4.x 1/1] net: neighbour: Add mcast_resolicit
 to configure the number of multicast resolicitations in PROBE state
Date: Tue, 24 Mar 2015 19:35:38 +0900
Message-ID: <55113DFA.9080608@miraclelinux.com>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com> <1427190355-1216-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>, lizefan@huawei.com,
	netdev@vger.kernel.org, ulf.samuelsson@ericsson.com,
	yoshfuji@linux-ipv6.org, Alexandre.Dietsch@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og128.obsmtp.com ([64.18.2.121]:47614 "HELO
	exprod7og128.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752506AbbCXKfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 06:35:42 -0400
Received: by mail-pd0-f175.google.com with SMTP id ni2so217492111pdb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 03:35:41 -0700 (PDT)
In-Reply-To: <1427190355-1216-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Zhu Yanjun wrote:

> We send unicast neighbor (ARP or NDP) solicitations ucast_probes
> times in PROBE state.  Zhu Yanjun reported that some implementation
> does not reply against them and the entry will become FAILED, which
> is undesirable.
> 
> We had been dealt with such nodes by sending multicast probes mcast_
> solicit times after unicast probes in PROBE state.  In 2003, I made

I?  Or please Add the From: to change the author to me.

> a change not to send them to improve compatibility with IPv6 NDP.
> 
> Let's introduce per-protocol per-interface sysctl knob "mcast_
> reprobe" to configure the number of multicast (re)solicitation for
> reconfirmation in PROBE state.  The default is 0, since we have
> been doing so for 10+ years.
> 

You should say: 'This patch is based on commit foobar ("title") by
author...' or something here.

> Reported-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> CC: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> [Zhu Yanjun: since kernel 3.4.x is different from mainline kernel(kernel 4.0-rcX).
> This patch is modified a lot.]
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

> ---
>  include/linux/neighbour.h |  1 +
>  include/net/neighbour.h   |  1 +
>  net/core/neighbour.c      | 20 +++++++++++++++++---
>  3 files changed, 19 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
> index b188f68..6945f4f 100644
> --- a/include/linux/neighbour.h
> +++ b/include/linux/neighbour.h
> @@ -112,6 +112,7 @@ enum {
>  	NDTPA_APP_PROBES,		/* u32 */
>  	NDTPA_UCAST_PROBES,		/* u32 */
>  	NDTPA_MCAST_PROBES,		/* u32 */
> +	NDTPA_MCAST_REPROBES,		/* u32 */
>  	NDTPA_ANYCAST_DELAY,		/* u64, msecs */
>  	NDTPA_PROXY_DELAY,		/* u64, msecs */
>  	NDTPA_PROXY_QLEN,		/* u32 */

No, this breaks binary compatibility.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
