From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 5/5] tcp: plug dst leak in tcp_v6_conn_request()
Date: Sun, 24 Jun 2012 13:12:33 -0400
Message-ID: <CADVnQykuAQcj_i5cZQphKnnoHaCPMd6xLBmq1ZSAeZs83z3tfw@mail.gmail.com>
References: <1340515324-2152-1-git-send-email-ncardwell@google.com>
	<1340515324-2152-5-git-send-email-ncardwell@google.com>
	<1340523678.23933.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:65459 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000Ab2FXRMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 13:12:34 -0400
Received: by obbuo13 with SMTP id uo13so5177118obb.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 10:12:34 -0700 (PDT)
In-Reply-To: <1340523678.23933.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 24, 2012 at 3:41 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2012-06-24 at 01:22 -0400, Neal Cardwell wrote:
>> The code in tcp_v6_conn_request() was implicitly assuming that
>> tcp_v6_send_synack() would take care of dst_release(), much as
>> tcp_v4_send_synack() already does. This resulted in
>> tcp_v6_conn_request() leaking a dst if sysctl_tw_recycle is enabled.
>>
>> This commit restructures tcp_v6_send_synack() so that it accepts a dst
>> pointer and takes care of releasing the dst that is passed in, to plug
>> the leak and avoid future surprises by bringing the IPv6 behavior in
>> line with the IPv4 side.
>
> I feel a bit uncomfortable to send a mix of 3 patches to fix one bug.
>
> Could you instead send pure fix (fixing dst leak) for net tree ?
>
> Then, when fix is incorporated in net-next, send the cleanups ?
>
> This also clashes with this pending work, so it would ease things if you
> can respin the cleanups for net-next
>
> http://patchwork.ozlabs.org/patch/166737/

Yes, the patches in this series were generated as patches against the
"net" tree (sorry for not indicating that).

The dst leak on the v6 sysctl_tw_recycle code path (patches 2-5) seems
like a pretty low priority, so I think we could simplify your plan
even a little further... How about this as a plan: we could apply the
first patch in the series (tcp: heed result of
security_inet_conn_request() in tcp_v6_conn_request()) to the net tree
now, and skip patches 2-5 for now. Once your pending synack work is in
net-next, I can respin patches 2-5 for net-next. How does that sound?

neal
