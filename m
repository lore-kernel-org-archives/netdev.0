From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 08 Mar 2010 09:29:02 -0800
Message-ID: <m11vfuvi1t.fsf@fess.ebiederm.org>
References: <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>
	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>
	<m1vdda1pmx.fsf@fess.ebiederm.org> <4B926B1B.5070207@free.fr>
	<m1aaulyy5c.fsf@fess.ebiederm.org> <4B92C886.9020507@free.fr>
	<m1fx4bxlfy.fsf@fess.ebiederm.org> <4B952BBE.6070507@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B952BBE.6070507@free.fr> (Daniel Lezcano's message of "Mon\, 08 Mar 2010 17\:54\:22 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> Eric W. Biederman wrote:
>> I have take an snapshot of my development tree and placed it at.
>>
>>
>> git://git.kernel.org/pub/scm/linux/people/ebiederm/linux-2.6.33-nsfd-v5.git
>>   
>
> Hi Eric,
>
> thanks for the pointer.
>
> I tried to boot the kernel under qemu and I got this oops:

I am clearly running an old userspace on my test machine.  No udev.
It looks like udev has a long standing netlink misfeature, where
it does not initializing NETLINK_CB....


>From 8d85e3ab88718eda3d94cf8e1be14b69dae2b8f1 Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Mon, 8 Mar 2010 09:25:20 -0800
Subject: [PATCH] kobject_uevent:  Use the netlink allocator helper...

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 lib/kobject_uevent.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 920a3ca..b8229cc 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -216,7 +216,7 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 
 		/* allocate message with the maximum possible size */
 		len = strlen(action_string) + strlen(devpath) + 2;
-		skb = alloc_skb(len + env->buflen, GFP_KERNEL);
+		skb = nlmsg_new(len + env->buflen, GFP_KERNEL);
 		if (skb) {
 			char *scratch;
 
-- 
1.6.5.2.143.g8cc62
