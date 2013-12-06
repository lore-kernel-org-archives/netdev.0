From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH] unix: fix build warning of used uninitialized variable
Date: Fri, 6 Dec 2013 14:38:33 +0800
Message-ID: <52A170E9.9020801@huawei.com>
References: <52A16924.9050407@huawei.com> <1386311079.30495.236.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <edumazet@google.com>,
	<ebiederm@xmission.com>, <gaofeng@cn.fujitsu.com>,
	<jacob.e.keller@intel.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:9629 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab3LFGjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:39:37 -0500
In-Reply-To: <1386311079.30495.236.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/6 14:24, Eric Dumazet wrote:
> On Fri, 2013-12-06 at 14:05 +0800, Wang Weidong wrote:
>> af_unix.c: In function unix_bind
>> af_unix.c:893: warning: path may be used uninitialized in this function
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  net/unix/af_unix.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 01625cc..4155ed3 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -893,6 +893,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>>  		struct path path;
>>  		umode_t mode = S_IFSOCK |
>>  		       (SOCK_INODE(sock)->i_mode & ~current_umask());
>> +		memset(&path, 0, sizeof(path));
>>  		err = unix_mknod(sun_path, mode, &path);
>>  		if (err) {
>>  			if (err == -EEXIST)
> 
> You should update your compiler, this patch is not needed.
> 
> 
Ok.

Thanks!

> 
> 
> 
