From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 5 Jan 2010 15:40:57 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi>
References: <4B4317AD.1040302@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>,
	Julian Anastasov <ja@ssi.bg>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53540 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab0AENk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 08:40:59 -0500
In-Reply-To: <4B4317AD.1040302@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Jan 2010, Daniel Lezcano wrote:

> I noticed a change in the value returned by the getsockopt for the
> TCP_DEFER_ACCEPT option with a 2.6.32 kernel. The value retrieved with the
> getsockopt is different from the one specified with the setsockopt. Is it an
> expected behaviour ?
> 
> I saw there were  changes around the TCP_DEFER_ACCEPT option with the number
> of attempts converted to a number of seconds.
> 
> The following program is working fine with a 2.6.31 but fails with a 2.6.32
> kernel.
> 
> Thanks
>  -- Daniel
> 
> #include <stdio.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <netinet/tcp.h>
> 
> int main(int argc, char *argv[])
> {
>    int val1 = 12, val2;
>    socklen_t len = sizeof(val2);
>    int fd;
>      fd = socket(PF_INET, SOCK_STREAM, 0);
>    if (fd < 0) {
>        perror("socket");
>        return -1;
>    }
>      if (setsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val1, sizeof(val1))) {
>        perror("setsockopt");
>        return -1;
>    }
>      if (getsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val2, &len)) {
>        perror("getsockopt");
>        return -1;
>    }
> 
>    if (val1 != val2) {
>        fprintf(stderr, "error %d != %d\n", val1, val2);
>        return -1;
>    }
> 
>    return 0;
> }

Added Cc.

I don't think this change was intentional. ...However, is this difference 
particularly significant besides failing such a test program? The actual 
value now returned by the getsockopt is more accurate than what the
userspace initially provided.

In general, I wonder if there's something that mandates that a set/get 
pair of value should be equal?

-- 
 i.
