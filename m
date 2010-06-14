From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 8/8] af_unix: Allow connecting to sockets in other network
 namespaces.
Date: Mon, 14 Jun 2010 15:37:31 +0200
Message-ID: <4C16309B.3010908@free.fr>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m11vcbgimj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:58234 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888Ab0FNNhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 09:37:45 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o5EDbiqI010628
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 13:37:44 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EDbicV663626
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 14:37:44 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o5EDbhjc017195
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 14:37:44 +0100
In-Reply-To: <m11vcbgimj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2010 03:35 PM, Eric W. Biederman wrote:
> Remove the restriction that only allows connecting to a unix domain
> socket identified by unix path that is in the same network namespace.
>
> Crossing network namespaces is always tricky and we did not support
> this at first, because of a strict policy of don't mix the namespaces.
> Later after Pavel proposed this we did not support this because no one
> had performed the audit to make certain using unix domain sockets
> across namespaces is safe.
>
> What fundamentally makes connecting to af_unix sockets in other
> namespaces is safe is that you have to have the proper permissions on
> the unix domain socket inode that lives in the filesystem.  If you
> want strict isolation you just don't create inodes where unfriendlys
> can get at them, or with permissions that allow unfriendlys to open
> them.  All nicely handled for us by the mount namespace and other
> standard file system facilities.
>
> I looked through unix domain sockets and they are a very controlled
> environment so none of the work that goes on in dev_forward_skb to
> make crossing namespaces safe appears needed, we are not loosing
> controll of the skb and so do not need to set up the skb to look like
> it is comming in fresh from the outside world.  Further the fields in
> struct unix_skb_parms should not have any problems crossing network
> namespaces.
>
> Now that we handle SCM_CREDENTIALS in a way that gives useable values
> across namespaces.  There does not appear to be any operational
> problems with encouraging the use of unix domain sockets across
> containers either.
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
>    

Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>

