From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v5 00/10] per-cgroup tcp memory pressure
Date: Wed, 9 Nov 2011 16:02:55 -0200
Message-ID: <4EBAC04F.1010901@parallels.com>
References: <1320679595-21074-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paul@paulmenage.org>, <lizf@cn.fujitsu.com>,
	<kamezawa.hiroyu@jp.fujitsu.com>, <ebiederm@xmission.com>,
	<davem@davemloft.net>, <gthelen@google.com>, <netdev@vger.kernel.org>,
	<linux-mm@kvack.org>, <kirill@shutemov.name>, <avagin@parallels.com>,
	<devel@openvz.org>, <eric.dumazet@gmail.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1320679595-21074-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 11/07/2011 01:26 PM, Glauber Costa wrote:
> Hi all,
>
> This is my new attempt at implementing per-cgroup tcp memory pressure.
> I am particularly interested in what the network folks have to comment on
> it: my main goal is to achieve the least impact possible in the network code.
>
> Here's a brief description of my approach:
>
> When only the root cgroup is present, the code should behave the same way as
> before - with the exception of the inclusion of an extra field in struct sock,
> and one in struct proto. All tests are patched out with static branch, and we
> still access addresses directly - the same as we did before.
>
> When a cgroup other than root is created, we patch in the branches, and account
> resources for that cgroup. The variables in the root cgroup are still updated.
> If we were to try to be 100 % coherent with the memcg code, that should depend
> on use_hierarchy. However, I feel that this is a good compromise in terms of
> leaving the network code untouched, and still having a global vision of its
> resources. I also do not compute max_usage for the root cgroup, for a similar
> reason.
>
> Please let me know what you think of it.

Dave, Eric,

Can you let me know what you think of the general approach I've followed 
in this series? The impact on the common case should be minimal, or at 
least as expensive as a static branch (0 in most arches, I believe).

I am mostly interested in knowing if this a valid pursue path. I'll be 
happy to address any specific concerns you have once you're ok with the 
general approach.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
