From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Thu, 7 Apr 2016 12:09:28 -0700
Message-ID: <20160407190928.GA31235@kafai-mba.local>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
 <1459551391-69969-4-git-send-email-kafai@fb.com>
 <CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
 <20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
 <CAM_iQpXV8UrBycmmTn3-FFEoR69OSvc4cWZMGbPnGiHF5aF7Dg@mail.gmail.com>
 <20160406001141.GA97608@kafai-mba.local>
 <CAM_iQpUrcXwBH0BuCh-cjo0st6ykpUgdjRo3Cn-ViO40vtbHKA@mail.gmail.com>
 <20160406184851.GA14894@kafai-mba.local>
 <CAM_iQpXbOj_zuQqHUie_yBOXqBEehHhF2FU8FA+tr7hgYY4QZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:31631 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932078AbcDGTJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 15:09:44 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXbOj_zuQqHUie_yBOXqBEehHhF2FU8FA+tr7hgYY4QZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 11:37:10AM -0700, Cong Wang wrote:
> You are lost in discussion
Indeed. :(

>
> I still think it is okay without the lock, because even if you take the lock,
> the pmtu update could still happen after you release it, so there is no
> essential difference here. The only reason I can think of for taking
> the sock lock is protecting parallel pmtu update, but it looks safe for
> this case too.
>
> So which case do you want to protect by taking the sock lock?
When the pmtu-update is doing route lookup and another connect is
happening, what sk->sk_v6_daddr will this route lookup use?
the old one, new one or neither of them?

Is it acceptable that getsockopt() is returning something that it
is not currently connected to? and potentially somewhere that it
is never connected to?
