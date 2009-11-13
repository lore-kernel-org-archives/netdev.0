From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 2/7 RFC] TCPCT part 1b: generate Responder
 Cookie
Date: Fri, 13 Nov 2009 09:35:36 -0500
Message-ID: <4AFD6EB8.20406@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCDDC4.1090606@gmail.com> <4AFCFAD0.4010701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:38766 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375AbZKMOfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 09:35:38 -0500
Received: by fxm21 with SMTP id 21so528026fxm.21
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 06:35:43 -0800 (PST)
In-Reply-To: <4AFCFAD0.4010701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Small point :
> 
> +	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
> +		spin_lock_bh(&tcp_secret_locker);
> +		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
> +			/* refreshed by another */
> +			spin_unlock_bh(&tcp_secret_locker);
> +			memcpy(bakery,
> +			       &tcp_secret_generating->secrets[0],
> +			       sizeof(tcp_secret_generating->secrets));
> 
> Technically speaking, you should perform the memcpy() before spin_unlock_bh()
> 
> +	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
> +		spin_lock_bh(&tcp_secret_locker);
> +		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
> +			/* refreshed by another */
> +			memcpy(bakery,
> +			       &tcp_secret_generating->secrets[0],
> +			       sizeof(tcp_secret_generating->secrets));
> +			spin_unlock_bh(&tcp_secret_locker);
> 
Technically speaking is exactly what I need!  I'd thought from your
earlier description of memory barriers that it should be after the unlock.
Done.
