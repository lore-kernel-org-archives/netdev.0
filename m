From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH 09/15] [TCP]: Introduce tcp_hdrlen() and tcp_optlen()
Date: Tue, 13 Mar 2007 16:22:37 -0700
Message-ID: <4807377b0703131622w5dde4304v63fd941f74719a27@mail.gmail.com>
References: <39e6f6c70703131446r3341c6c0i2a8168fdfcbde868@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Netdev List" <netdev@vger.kernel.org>
To: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:14501 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbXCMXWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 19:22:38 -0400
Received: by an-out-0708.google.com with SMTP id b33so2081080ana
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2007 16:22:38 -0700 (PDT)
In-Reply-To: <39e6f6c70703131446r3341c6c0i2a8168fdfcbde868@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/13/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> Introduce tcp_hdrlen() and tcp_optlen():
> The ip_hdrlen() buddy, created to reduce the number of skb->h.th-> uses and to
> avoid the longer, open coded equivalent.

+static inline unsigned int tcp_hdrlen(const struct sk_buff *skb)
+{
+	return skb->h.th->doff * 4;
+}
+
+static inline unsigned int tcp_optlen(const struct sk_buff *skb)
+{
+	return (skb->h.th->doff - 5) * 4;
+}

acme, good stuff, but does the " * 4" generate equivalent assembly
with gcc 3/4 as " << 2" ?

I could assume that the compiler would be smart enough, but every time
I assume I know what the compiler is doing I get myself in trouble.
