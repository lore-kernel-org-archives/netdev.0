From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Sat, 26 Sep 2015 21:44:45 -0400
Message-ID: <877fnc7i0i.fsf@bytheb.org>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tolga Ceylan <tolga.ceylan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36766 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720AbbI0Bos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 21:44:48 -0400
Received: by qgx61 with SMTP id 61so97035612qgx.3
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 18:44:47 -0700 (PDT)
In-Reply-To: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com> (Tolga
	Ceylan's message of "Sat, 26 Sep 2015 17:30:48 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings.

Tolga Ceylan <tolga.ceylan@gmail.com> writes:
> +#define SO_REUSEPORT_LISTEN_OFF 51
> +
For all of these, I think the space should be tab.

> 	unsigned char		skc_reuseport:1;
>+	unsigned char       skc_reuseport_listen_off:1;
> 	unsigned char		skc_ipv6only:1;
The spacing here is wrong.

> @@ -224,10 +224,13 @@ begin:
>  				phash = inet_ehashfn(net, daddr, hnum,
>  						     saddr, sport);
>  				matches = 1;
> +				if (sk->sk_reuseport_listen_off)
> +					result = NULL;
I am concerned here. I think you need to reset hiscore and matches as
well, not just result.
