From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 5/5] sock_diag: notify when filter change
Date: Wed, 24 Apr 2013 10:13:26 +0200
Message-ID: <51779426.7020800@6wind.com>
References: <1366727277-19522-1-git-send-email-nicolas.dichtel@6wind.com> <1366727277-19522-6-git-send-email-nicolas.dichtel@6wind.com> <kl83nr$8t3$1@ger.gmane.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36899 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757446Ab3DXINa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 04:13:30 -0400
Received: by mail-wi0-f181.google.com with SMTP id c10so1795736wiw.14
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 01:13:29 -0700 (PDT)
In-Reply-To: <kl83nr$8t3$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/04/2013 10:05, Cong Wang a =E9crit :
> On Tue, 23 Apr 2013 at 14:27 GMT, Nicolas Dichtel <nicolas.dichtel@6w=
ind.com> wrote:
>> @@ -773,6 +775,7 @@ int sk_detach_filter(struct sock *sk)
>>   		RCU_INIT_POINTER(sk->sk_filter, NULL);
>>   		sk_filter_uncharge(sk, filter);
>>   		ret =3D 0;
>> +		sock_diag_notify(sk, 1);
>
> Should be sock_diag_notify(sk, 0)?
No, the filter is removed but the socket is still alive.
0 means that the socket is destroyed.

>
> BTW, use 'true' and 'false' instead of '1' and '0'.
Will do.
