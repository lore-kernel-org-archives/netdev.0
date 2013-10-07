From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Update the sysctl permissions handler to test
 effective uid/gid
Date: Mon, 07 Oct 2013 15:58:26 -0400 (EDT)
Message-ID: <20131007.155826.1149781445759202780.davem@davemloft.net>
References: <5249DAA7.9050304@redhat.com>
	<CAGXu5j+88Bb0Mnbiyq-bTzkn59YXOefCrXtht-evYhq-yUfYFg@mail.gmail.com>
	<87y567lbj1.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sandeen@redhat.com, akpm@linux-foundation.org, security@kernel.org,
	pmatouse@redhat.com, netdev@vger.kernel.org, keescook@google.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986Ab3JGT62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:58:28 -0400
In-Reply-To: <87y567lbj1.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 05 Oct 2013 13:15:30 -0700

> 
> On Tue, 20 Aug 2013 11:40:04 -0500 Eric Sandeen <sandeen@redhat.com> wrote:
>> This was brought up in a Red Hat bug (which may be marked private, I'm sorry):
>>
>> Bug 987055 - open O_WRONLY succeeds on some root owned files in /proc for process running with unprivileged EUID
>>
>> "On RHEL7 some of the files in /proc can be opened for writing by an unprivileged EUID."
>>
>> The flaw existed upstream as well last I checked.
>>
>> This commit in kernel v3.8 caused the regression:
>>
>> commit cff109768b2d9c03095848f4cd4b0754117262aa
>> Author: Eric W. Biederman <ebiederm@xmission.com>
>> Date:   Fri Nov 16 03:03:01 2012 +0000
>>
>>     net: Update the per network namespace sysctls to be available to the network namespace owner
>>
>>     - Allow anyone with CAP_NET_ADMIN rights in the user namespace of the
>>       the netowrk namespace to change sysctls.
>>     - Allow anyone the uid of the user namespace root the same
>>       permissions over the network namespace sysctls as the global root.
>>     - Allow anyone with gid of the user namespace root group the same
>>       permissions over the network namespace sysctl as the global root group.
>>
>>     Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> because it changed /sys/net's special permission handler to test current_uid, not
>> current_euid; same for current_gid/current_egid.
>>
>> So in this case, root cannot drop privs via set[ug]id, and retains all privs
>> in this codepath.
> 
> Modify the code to use current_euid(), and in_egroup_p, as in done
> in fs/proc/proc_sysctl.c:test_perm()
> 
> Cc: stable@vger.kernel.org
> Reviewed-by: Eric Sandeen <sandeen@redhat.com>
> Reported-by: Eric Sandeen <sandeen@redhat.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied and queued up for -stable, thanks.
