From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: very strange inet_sock corruption with rpc
Date: Thu, 26 Apr 2007 10:00:50 -0300
Message-ID: <39e6f6c70704260600n1cd879e7u6a284b1235425db3@mail.gmail.com>
References: <462FC238.4040305@hp.com> <200704260849.41485.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Vlad Yasevich" <vladislav.yasevich@hp.com>,
	netdev <netdev@vger.kernel.org>
To: "Olaf Kirch" <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:3901 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030864AbXDZNAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 09:00:52 -0400
Received: by ik-out-1112.google.com with SMTP id c30so585701ika
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 06:00:50 -0700 (PDT)
In-Reply-To: <200704260849.41485.okir@lst.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/26/07, Olaf Kirch <okir@lst.de> wrote:
> On Wednesday 25 April 2007 23:03, Vlad Yasevich wrote:
> > It looks like someone is stepping all over the inet_sock.
> > We'll continue looking, but if anyone has any ideas of what might
> > be going on, I'd appreciate it.
>
> This could be a socket in TIME_WAIT. A socket entering
> TIME_WAIT will be replaced by an inet_timewait_sock, which is
> a kind of truncated inet_sock.

I bet it is, as all the members that are touched without checking if
it is a TIME_WAIT sockets are in the common part, struct sock_common,
and things like inet_v6_ipv6only() and inet_rcv_saddr() check if it is
a TIME_WAIT socket.

So please do this check:

if (sk->sk_state != TCP_TIME_WAIT)

before testing the new fields in inet_sock :-)

- Arnaldo
