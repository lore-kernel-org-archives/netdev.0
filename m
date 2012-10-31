From: jing wang <windsdaemon@gmail.com>
Subject: Re: [PATCH 1/1] net: fix compile warning in af_unix.c
Date: Wed, 31 Oct 2012 08:46:09 +0800
Message-ID: <509074D1.3000306@gmail.com>
References: <1351581396-20493-1-git-send-email-windsdaemon@gmail.com> <20121030070040.5bdf0f0a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:50994 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab2JaAq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 20:46:29 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so556705pad.19
        for <netdev@vger.kernel.org>; Tue, 30 Oct 2012 17:46:28 -0700 (PDT)
In-Reply-To: <20121030070040.5bdf0f0a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B410=E6=9C=8830=E6=97=A5 22:00, Stephen Hemminger =
=E5=86=99=E9=81=93:
> On Tue, 30 Oct 2012 15:16:36 +0800
> Jing Wang <windsdaemon@gmail.com> wrote:
>
>> This patch fix some compile warning as follows:
>> net/unix/af_unix.c: In function 'unix_bind':
>> net/unix/af_unix.c:895: warning: 'path.dentry' may be used uninitial=
ized in this function
>> net/unix/af_unix.c:895: warning: 'path.mnt' may be used uninitialize=
d in this function
>>
>> Signed-off-by: Jing Wang <windsdaemon@gmail.com>
>> ---
>>   net/unix/af_unix.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 5b5c876..9f710ac 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -895,6 +895,8 @@ static int unix_bind(struct socket *sock, struct=
 sockaddr *uaddr, int addr_len)
>>   		struct path path;
>>   		umode_t mode =3D S_IFSOCK |
>>   		       (SOCK_INODE(sock)->i_mode & ~current_umask());
>> +		path.mnt =3D NULL;
>> +		path.dentry =3D NULL;
>>   		err =3D unix_mknod(sun_path, mode, &path);
>>   		if (err) {
>>   			if (err =3D=3D -EEXIST)
> I appreciate the effort to silence warnings. But this warning is a fa=
lse
> positive that only occurs on some versions of Gcc. With gcc 4.7 the
> warning does not occur.
>
> The general consensus has been NOT to do initializations or other cha=
nges
> if the problem is due to Gcc bug.
>
Thanks for you review, you're right, the version of my gcc is 4.4.6 !
