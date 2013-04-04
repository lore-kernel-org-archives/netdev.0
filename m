From: dingtianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] af_unix: fix build warning
Date: Thu, 4 Apr 2013 15:00:34 +0800
Message-ID: <515D2512.5040908@huawei.com>
References: <515BF6DA.9010007@huawei.com> <CAKoUArk67UyqAC26t7JCfL_LZWHAO1qB=dH=chaXHd-jsxrPfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:58058 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763852Ab3DDHB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 03:01:27 -0400
In-Reply-To: <CAKoUArk67UyqAC26t7JCfL_LZWHAO1qB=dH=chaXHd-jsxrPfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/4/3 20:27, Rami Rosen wrote:
> Hi,
> Which version of gcc are you using ?
> A patch like yours, for the same method, unix_bind(), was sent in the
> past, and Stephen Hemminger noted the
> with gcc 4.7 the warning you got does not occur.
> see:
> http://permalink.gmane.org/gmane.linux.network/247807
>=20
> Best Regards,
>=20
> Rami Rosen
> http://ramirose.wix.com/ramirosen
>=20

ok,thanks

>=20
> On Wed, Apr 3, 2013 at 12:31 PM, dingtianhong <dingtianhong@huawei.co=
m> wrote:
>> net/unix/af_unix.c: In function =91unix_bind=92:
>> net/unix/af_unix.c:892: warning: =91path.mnt=92 may be used uninitia=
lized in this function
>> net/unix/af_unix.c:892: warning: =91path.dentry=92 may be used unini=
tialized in this function
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  net/unix/af_unix.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 971282b..3ccc049 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -889,7 +889,7 @@ static int unix_bind(struct socket *sock, struct=
 sockaddr *uaddr, int addr_len)
>>         atomic_set(&addr->refcnt, 1);
>>
>>         if (sun_path[0]) {
>> -               struct path path;
>> +               struct path path =3D {};
>>                 umode_t mode =3D S_IFSOCK |
>>                        (SOCK_INODE(sock)->i_mode & ~current_umask())=
;
>>                 err =3D unix_mknod(sun_path, mode, &path);
>> --
>> 1.8.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
