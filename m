From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v2 2/9] Kernel Memory cgroup
Date: Wed, 7 Sep 2011 02:55:48 -0300
Message-ID: <4E670764.1040805@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-3-git-send-email-glommer@parallels.com> <CALdu-PCosvJ-SfVROLLM29RoMfxxRyW9E-_Za9A7LTAZwmkPeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<containers@lists.osdl.org>, <netdev@vger.kernel.org>, <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa
	<kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>
To: Paul Menage <paul@paulmenage.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CALdu-PCosvJ-SfVROLLM29RoMfxxRyW9E-_Za9A7LTAZwmkPeg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 09/07/2011 02:24 AM, Paul Menage wrote:
> On Tue, Sep 6, 2011 at 9:23 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> +
>> +struct kmem_cgroup {
>> +       struct cgroup_subsys_state css;
>> +       struct kmem_cgroup *parent;
>> +};
>
> There's a parent pointer in css.cgroup, so you shouldn't need a
> separate one here.

Ok, I missed that. Thanks

> Most cgroup subsystems define this structure (and the below accessor
> functions) in their .c file rather than exposing it to the world? Does
> this subsystem particularly need it exposed?

Originally I was using it in sock.c and friends. Now, from the last 
submission to this one, most of those uses were substituted. The 
acessors, however, are in kmem_cgroup.h. Reason being I want most of 
them to be inline.

>> +
>> +static struct cgroup_subsys_state *kmem_create(
>> +       struct cgroup_subsys *ss, struct cgroup *cgrp)
>> +{
>> +       struct kmem_cgroup *sk = kzalloc(sizeof(*sk), GFP_KERNEL);
>
> kcg or just cg would be a better name?

I'll go with kcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
