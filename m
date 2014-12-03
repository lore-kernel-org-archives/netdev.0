From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of
 list_for_each_entry_rcu
Date: Thu, 04 Dec 2014 00:15:13 +0100
Message-ID: <547F9981.8050809@redhat.com>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us> <1417539636-12710-4-git-send-email-jiri@resnulli.us> <547F0743.4040301@mojatatu.com> <20141203132635.GH1860@nanopsycho.orion> <547F203A.3080208@mojatatu.com> <20141203152051.GK1860@nanopsycho.orion> <547F7D6D.3000709@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520AbaLCXPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 18:15:24 -0500
In-Reply-To: <547F7D6D.3000709@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2014 10:15 PM, Jamal Hadi Salim wrote:
...
> I am not an rcu officionado. So if the control path is doing a non-rcu
> get + rcu-del/change (update) then as long as the fastpath is (read)
> rcu locking we are fine  and nothing will actually happen until the
> fastpath releases and rcu grace period ends, correct?

So if the control path does a list_del_rcu() and call_rcu() under
lock and iterates over list_for_each_entry{,safe}() [which we do
in cls_bpf_delete()], while the fast path [cls_bpf_classify()] uses
a rcu_read_{un,}lock() with *_rcu list iterator, that's fine then,
as it's still guaranteed to be deleted after the grace period. So
Jiri's change looks good to me.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
