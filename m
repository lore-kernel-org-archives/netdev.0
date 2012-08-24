From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: netlink scm creds uid and gids are always 0.
Date: Fri, 24 Aug 2012 02:07:42 -0700
Message-ID: <877gsok68x.fsf@xmission.com>
References: <871uiwlrf3.fsf@xmission.com>
	<1345795065.5904.2287.camel@edumazet-glaptop>
	<87txvsk8h7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51956 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636Ab2HXJHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 05:07:53 -0400
In-Reply-To: <87txvsk8h7.fsf@xmission.com> (Eric W. Biederman's message of
	"Fri, 24 Aug 2012 01:19:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Eric Dumazet <eric.dumazet@gmail.com> writes:
>
>> On Thu, 2012-08-23 at 23:45 -0700, Eric W. Biederman wrote:
>>> While working on the kuid_t and kgid_t conversion of the audit subsystem
>>> I noticed that since the performance problem of scm creds and af_unix
>>> sockets were fixed af_netlink sockets have not filled in the uid or gid
>>> of the originator of the socket.
>>> 
>>> I think all we need is an appropriate cred_to_ucred call to fix this
>>> regression, but I am going so many different directions right now I
>>> can't get myself to focus on this long enough to work up an appripriate
>>> patch to fix.
>>> 
>>> Eric do you think you might take a gander?
>>
>> Wasnt it fixed by e0e3cea46d31d23dc40df0a49a7a2c04fe8edfea
>>
>> af_netlink: force credentials passing [CVE-2012-3520]
>>
>> Or is it a different thing ?
>
> Same thing.  I didn't see that fix go by.
>
> One more little thing I can cross off my list.  Hooray!

Looking a little deeper it looks like I am going to have to
give scm credentials a little more tender loving care.

There is still a possible issue with netlink sockets and pids when the
two processes talking over netlink are in different pid namespaces.

And I need to take care in my usernamespace tree for 3.7, to keep from
reintroucing the ability to spoof root if the two netlink talkers are in
different user namespaces. 

With a little luck for uids and gids I can just pass around kuid_t and
kgid_t values and throw out the ref-counting complexity.  Something
to sleep on and benchmark, and then generate a patch I guess.

I know at least from my last attempt that ref counting in the NETLINK_CB
was a lost cause.  So I don't know what to do about the pids :(

Eric
