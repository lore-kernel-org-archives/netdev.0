From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Tue, 22 Jul 2008 08:14:16 -0400
Message-ID: <6599ad830807220514m5afea0fcsb99bf2e95f401c36@mail.gmail.com>
References: <Pine.LNX.4.64.0807212100580.1760@ranjit.corp.google.com>
	 <4885B7DD.7070507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ranjit Manomohan" <ranjitm@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754831AbYGVMOi@vger.kernel.org>
In-Reply-To: <4885B7DD.7070507@trash.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 22, 2008 at 6:35 AM, Patrick McHardy <kaber@trash.net> wrote:
>
> Does this really have to be a new skb member? You could
> simply use skb->sk->sk_cgroup_classid directly, or if
> that doesn't work, maybe skb->priority.
>

We were actually using skb->priority in our internal version of this
patch. I suggested that the separate cgroup_classid field be added
since it might be considered an abuse of skb->priority and would
interfere with existing users of that. If that's not an issue then
reusing skb->priority is certainly possible.

Regarding skb->sk->sk_cgroup_classid, is it always the case that the
original sk is still available when we're making traffic control
decisions? I'd thought that there were cases (e.g. cloning skbs in the
TCP retransmit path) where the pointer to the original sk is lost.

Paul
