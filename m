From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v2] cgroup: net_cls: fix false-positive "suspicious RCU
 usage"
Date: Wed, 22 Jul 2015 14:06:57 +0200
Message-ID: <55AF8761.5020804@iogearbox.net>
References: <20150721164629.18385.14538.stgit@buzz> <20150722092320.30663.86742.stgit@buzz> <55AF84FC.2070502@iogearbox.net> <55AF869E.4030304@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55AF869E.4030304-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/22/2015 02:03 PM, Konstantin Khlebnikov wrote:
> On 22.07.2015 14:56, Daniel Borkmann wrote:
>> On 07/22/2015 11:23 AM, Konstantin Khlebnikov wrote:
>>> In dev_queue_xmit() net_cls protected with rcu-bh.
>> ...
>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
>>> ---
>>>   net/core/netclassid_cgroup.c |    3 ++-
>>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
>>> index 1f2a126f4ffa..6441f47b1a8f 100644
>>> --- a/net/core/netclassid_cgroup.c
>>> +++ b/net/core/netclassid_cgroup.c
>>> @@ -23,7 +23,8 @@ static inline struct cgroup_cls_state
>>> *css_cls_state(struct cgroup_subsys_state
>>>
>>>   struct cgroup_cls_state *task_cls_state(struct task_struct *p)
>>>   {
>>> -    return css_cls_state(task_css(p, net_cls_cgrp_id));
>>> +    return css_cls_state(task_css_check(p, net_cls_cgrp_id,
>>> +                        rcu_read_lock_bh_held()));
>>
>> Did you also check that after your patch this doesn't trigger on ingress
>> either? There, this code path could be invoked under rcu_read_lock(). So,
>> perhaps you need to check for both.
>
> I haven't seen warnings with this patch. rcu_read_lock_held() is
> checked inside rcu_dereference_check() inside task_css_check().

Thanks, agreed.
