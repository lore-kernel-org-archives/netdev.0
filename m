From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v7 3/7 RFC] TCPCT part 1c: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS
Date: Sat, 21 Nov 2009 11:51:13 -0500
Message-ID: <4B081A81.5000602@gmail.com>
References: <4B06A1FF.8000202@gmail.com>	<4B06A8CF.3000303@gmail.com> <20091120.092408.208010931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:43982 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754806AbZKUQvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 11:51:11 -0500
Received: by yxe17 with SMTP id 17so3689034yxe.33
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 08:51:17 -0800 (PST)
In-Reply-To: <20091120.092408.208010931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Fri, 20 Nov 2009 09:33:51 -0500
> 
>> @@ -59,6 +59,14 @@ int sysctl_tcp_base_mss __read_mostly = 512;
>>  /* By default, RFC2861 behavior.  */
>>  int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
>>  
>> +#ifdef CONFIG_SYSCTL
>> +/* By default, let the user enable it. */
>> +int sysctl_tcp_cookie_size __read_mostly = 0;
>> +#else
>> +int sysctl_tcp_cookie_size __read_mostly = TCP_COOKIE_MAX;
>> +#endif
>> +
> 
> I would prefer if the default did not depend upon whether
> SYSCTL is enabled or not.  That's extremely non-intuitive.
> 
> 
This code was based on net/ipv4/tcp_minisocks.c for syncookies.
Apparently, default for syncookies has been controversial.

Would you accept always default to TCP_COOKIE_MAX?

The code already automatically reduces the size of the cookie to
match available space in the TCP options (part 1f).
