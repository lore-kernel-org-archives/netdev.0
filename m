From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 13:55:40 +0200
Message-ID: <48E3653C.1070701@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org> <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	benjamin.thery@bull.net, ebiederm@xmission.com, xemul@openvz.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:63212 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbYJALzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 07:55:49 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m91BtlJD105284
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 11:55:47 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91Btl933924156
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 12:55:47 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91Btk77015071
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 12:55:47 +0100
In-Reply-To: <1222860776.23573.49.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> On Wed, 2008-10-01 at 13:13 +0200, Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> This patch opens a way to connect via Unix socket from one namespace
>>> to another if these sockets are opened via conventional filesystem
>>> interface. Such approach allows to share important services between
>>> namespaces in efficient way.
>>>
>>> This breach is controlled by the means of shared filesystem, i.e. if
>>> somebody really wants to isolate containers, he should start from
>>> filesystem separation.
>>>
>>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>>> ---
>>>  net/unix/af_unix.c |    3 ---
>>>  1 files changed, 0 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>>> index 39d2173..0e1eccd 100644
>>> --- a/net/unix/af_unix.c
>>> +++ b/net/unix/af_unix.c
>>> @@ -297,9 +297,6 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
>>>  		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
>>>  		struct dentry *dentry = unix_sk(s)->dentry;
>>>
>>> -		if (!net_eq(sock_net(s), net))
>>> -			continue;
>>> -
>>>  		if(dentry && dentry->d_inode == i)
>>>  		{
>>>  			sock_hold(s);
>> Hi Denis,
>>
>> Do you have a list of the important services this isolation forbids ? (I 
>> suppose there is syslog).
> 
> we have asked from our customers for a shared MySQL server
> 
> The full story is here :)
> http://bugzilla.openvz.org/show_bug.cgi?id=985

Ok, thanks.

My question remains :)

How do you handle migration in this case ?
