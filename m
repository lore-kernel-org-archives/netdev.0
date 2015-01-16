From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] socket: use iov_length()
Date: Fri, 16 Jan 2015 14:31:54 +0100
Message-ID: <54B912CA.40305@6wind.com>
References: <1421230070-4104-1-git-send-email-nicolas.dichtel@6wind.com> <20150115214519.GB29656@ZenIV.linux.org.uk>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:36895 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbAPNb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:31:57 -0500
Received: by mail-wg0-f46.google.com with SMTP id x13so20531574wgg.5
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 05:31:56 -0800 (PST)
In-Reply-To: <20150115214519.GB29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/01/2015 22:45, Al Viro a =E9crit :
> On Wed, Jan 14, 2015 at 11:07:50AM +0100, Nicolas Dichtel wrote:
>> Better to use available helpers.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   net/socket.c | 8 ++------
>>   1 file changed, 2 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/socket.c b/net/socket.c
>> index a2c33a4dc7ba..b1f3fa4da020 100644
>> --- a/net/socket.c
>> +++ b/net/socket.c
>> @@ -883,10 +883,8 @@ static ssize_t do_sock_read(struct msghdr *msg,=
 struct kiocb *iocb,
>>   {
>>   	struct socket *sock =3D file->private_data;
>>   	size_t size =3D 0;
>> -	int i;
>>
>> -	for (i =3D 0; i < nr_segs; i++)
>> -		size +=3D iov[i].iov_len;
>> +	size =3D iov_length(iov, nr_segs);
>
> What's wrong with size =3D iocb->ki_nbytes instead of calling anythin=
g?
>
I'm not an expert, but it seems you're right. I will send a patch.
