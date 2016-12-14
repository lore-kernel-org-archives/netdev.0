From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH v3] audit: use proper refcount locking on audit_sock
Date: Tue, 13 Dec 2016 21:36:37 -0800
Message-ID: <CAM_iQpVuzYRAb4qFj1kPduxCUsAjkyik=qXriQcP6g7gPgyXRQ@mail.gmail.com>
References: <20161212100215.GA1305@madcap2.tricolour.ca> <61c37ca790bc11bc023aea8f9b70ab3098aa30f5.1481626466.git.rgb@redhat.com>
 <CAM_iQpVFkNdEirvBDi8wV=iExt9BnCm3KU7+Q8oqhrJJtcnu9Q@mail.gmail.com> <20161214040005.GL22660@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>, linux-audit@redhat.com,
        Dmitry Vyukov <dvyukov@google.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35258 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbcLNFzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 00:55:06 -0500
In-Reply-To: <20161214040005.GL22660@madcap2.tricolour.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 8:00 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2016-12-13 16:19, Cong Wang wrote:
>> On Tue, Dec 13, 2016 at 7:03 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
>> > @@ -1283,8 +1299,10 @@ static void __net_exit audit_net_exit(struct net *net)
>> >  {
>> >         struct audit_net *aunet = net_generic(net, audit_net_id);
>> >         struct sock *sock = aunet->nlsk;
>> > +       mutex_lock(&audit_cmd_mutex);
>> >         if (sock == audit_sock)
>> >                 auditd_reset();
>> > +       mutex_unlock(&audit_cmd_mutex);
>>
>> This still doesn't look correct to me, b/c here we release the audit_sock
>> refcnt twice:
>>
>> 1) inside audit_reset()
>
> The audit_reset() refcount decrement corresponds to a setting of
> audit_sock only if audit_sock is still non-NULL.
>

Hmm, thinking about it again, looks like the sock == audit_sock
and audit_sock != NULL checks can guarantee we are safe. So,

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
