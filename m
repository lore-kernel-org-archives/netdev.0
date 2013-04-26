From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: tun: release the reference of tun device in tun_recvmsg
Date: Fri, 26 Apr 2013 13:03:00 +0800
Message-ID: <517A0A84.40102@cn.fujitsu.com>
References: <201304250822.38944.a.miskiewicz@gmail.com> <1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com> <201304251704.42257.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52447 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751034Ab3DZFBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 01:01:07 -0400
In-Reply-To: <201304251704.42257.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2013 11:04 PM, Arkadiusz Miskiewicz wrote:
> On Thursday 25 of April 2013, Gao feng wrote:
>> We forget to release the reference of tun device in tun_recvmsg.
>> bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
>> (tuntap: move socket to tun_file)
> 
> Hm, still hitting the problem even with the patch - dmesg:
> 

Ok, seams there are another problems we haven't discovered.
it's excellent if you can find out which commit introduces this
bug by git bisect.

Thanks!

> http://pastebin.com/iSm0QJVY
> 
> 
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  drivers/net/tun.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 0c9df2f..dcd0c19 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1471,14 +1471,17 @@ static int tun_recvmsg(struct kiocb *iocb, struct
>> socket *sock, if (!tun)
>>  		return -EBADFD;
>>
>> -	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
>> -		return -EINVAL;
>> +	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC)) {
>> +		ret = -EINVAL;
>> +		goto out;
>> +	}
>>  	ret = tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
>>  			  flags & MSG_DONTWAIT);
>>  	if (ret > total_len) {
>>  		m->msg_flags |= MSG_TRUNC;
>>  		ret = flags & MSG_TRUNC ? ret : total_len;
>>  	}
>> +out:
>>  	tun_put(tun);
>>  	return ret;
>>  }
> 
> 
