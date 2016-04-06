From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Tue, 5 Apr 2016 17:11:41 -0700
Message-ID: <20160406001141.GA97608@kafai-mba.local>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
 <1459551391-69969-4-git-send-email-kafai@fb.com>
 <CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
 <20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
 <CAM_iQpXV8UrBycmmTn3-FFEoR69OSvc4cWZMGbPnGiHF5aF7Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48221 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751742AbcDFALv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 20:11:51 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXV8UrBycmmTn3-FFEoR69OSvc4cWZMGbPnGiHF5aF7Dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 01:45:02PM -0700, Cong Wang wrote:
> I see your point, but calling __ip6_datagram_connect() seems overkill
> here, we don't need to update so many things in the pmtu update context,
> at least IPv4 doesn't do that either. I don't think you have to do that.
>
> So why just updating the dst cache (also some addr cache) here is not
> enough?
I am not sure I understand.  I could be missing something.

This patch uses ip6_datagram_dst_update() to do the route lookup and
sk->sk_dst_cache update.  ip6_datagram_dst_update() is
created in the first two refactoring patches and is also used by
__ip6_datagram_connect().

Which operations in ip6_datagram_dst_update() could be saved
during the pmtu update?
