From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 21:42:58 -0400
Message-ID: <4BDB8722.5020401@cs.columbia.edu>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
	<4BDB3F07.2030900@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>,
        Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BDB3F07.2030900-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org



Daniel Lezcano wrote:
> Dan Smith wrote:
>> This patch adds support for checkpointing and restoring route information.
>> It keeps enough information to restore basic routes at the level of detail
>> of /proc/net/route.  It uses RTNETLINK to extract the information during
>> checkpoint and also to insert it back during restore.  This gives us a
>> nice layer of isolation between us and the various "fib" implementations.
>>
>> Changes in v2:
>>
>> This version of the patch actually moves the current task into the
>> desired network namespace temporarily, for the purposes of examining and
>> restoring the route information.  This is a instead of creating a cross-
>> namespace socket to do the job, as was done in v1.
>>
>> This is just an RFC to see if this is an acceptable method.  For a final
>> version, adding a helper to nsproxy.c would allow us to create a new
>> nsproxy with the desired netns instead of creating one with
>> copy_namespaces() just to kill it off and use the target one.
>>
>> I still think the previous method is cleaner, but this way may violate
>> fewer namespace boundaries (I'm still undecided :)
>>
>> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> Cc: Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>
>> Cc: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
>> ---
> Hi Dan,
> 
> Eric did a patchset (as Jamal mentioned it) where you can have a process 
> to enter a specific namespace from userspace.
> 
> http://git.kernel.org/?p=linux/kernel/git/ebiederm/linux-2.6.33-nsfd-v5.git;a=commit;h=9c2f86a44d9ca93e78fd8e81a4e2a8c2a4cdb054
> 
> Is it possible to enter the namespace and dump / restore the routes with 
> NETLINK_ROUTE from userspace ? Or is it something not possible ?
> 

I also think that restoring routes from userspace, if feasible,
will be advantageous.

Besides, that will simplify cases in which userspace would like to
restore something different (in terms of routes) than what was
saved in the checkpoint.

So the question is, what would it take ?

Oren.
