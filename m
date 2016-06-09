From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Fri, 10 Jun 2016 00:21:41 +0200
Message-ID: <5759EBF5.4010902@iogearbox.net>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com> <20160609213517.GA25288@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Florian Westphal <fw@strlen.de>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57173 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbcFIWVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 18:21:50 -0400
In-Reply-To: <20160609213517.GA25288@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2016 11:35 PM, Florian Westphal wrote:
> Saeed Mahameed <saeedm@mellanox.com> wrote:
>> index a1bd161..67de200 100644
>> --- a/net/socket.c
>> +++ b/net/socket.c
>> @@ -382,6 +382,7 @@ struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname)
>>   	}
>>
>>   	sock->file = file;
>> +	file->f_owner.sock_pid  = find_get_pid(task_pid_nr(current));
>>   	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
>>   	file->private_data = sock;
>>   	return file;
>
> This looks like this leaks sock_pid reference...?
>
> (find_get_pid -> get_pid -> atomic_inc() , I don't see a put_pid in the
>   patch)
>
> Can't comment further than this since I'm not familiar with vfs; e.g.
> I can't say if fown_struct is right place or not, or if this approach
> even works when creating process has exited after fork, etc.

Or ... if you xmit the fd via unix domain socket to a different process
and initial owner terminates, which should give you invalid information
then; afaik, this would just increase struct file's refcnt and hand out
an unused fdnum ( get_unused_fd_flags() + fd_install(), etc).
For extending 'struct fown_struct', you probably also need to Cc fs folks.
