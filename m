From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [RFC PATCH v3] audit: use proper refcount locking on audit_sock
Date: Tue, 13 Dec 2016 23:00:05 -0500
Message-ID: <20161214040005.GL22660@madcap2.tricolour.ca>
References: <20161212100215.GA1305@madcap2.tricolour.ca>
 <61c37ca790bc11bc023aea8f9b70ab3098aa30f5.1481626466.git.rgb@redhat.com>
 <CAM_iQpVFkNdEirvBDi8wV=iExt9BnCm3KU7+Q8oqhrJJtcnu9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>, linux-audit@redhat.com,
        Dmitry Vyukov <dvyukov@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpVFkNdEirvBDi8wV=iExt9BnCm3KU7+Q8oqhrJJtcnu9Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-12-13 16:19, Cong Wang wrote:
> On Tue, Dec 13, 2016 at 7:03 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > @@ -1283,8 +1299,10 @@ static void __net_exit audit_net_exit(struct net *net)
> >  {
> >         struct audit_net *aunet = net_generic(net, audit_net_id);
> >         struct sock *sock = aunet->nlsk;
> > +       mutex_lock(&audit_cmd_mutex);
> >         if (sock == audit_sock)
> >                 auditd_reset();
> > +       mutex_unlock(&audit_cmd_mutex);
> 
> This still doesn't look correct to me, b/c here we release the audit_sock
> refcnt twice:
> 
> 1) inside audit_reset()

The audit_reset() refcount decrement corresponds to a setting of
audit_sock only if audit_sock is still non-NULL.

> 2) netlink_kernel_release()

This refcount decrement corresponds to netlink_kernel_create().

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
