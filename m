From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Mon, 24 Sep 2012 19:31:18 +0200
Message-ID: <1348507878.26828.1271.camel@edumazet-glaptop>
References: <20120905043523.GA12988@redhat.com>
	 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
	 <20120914212958.GA25053@redhat.com>
	 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
	 <20120919211059.GA10985@redhat.com>
	 <1348092082.31352.51.camel@edumazet-glaptop>
	 <20120920020223.GA28110@redhat.com> <20120924153921.GA13845@redhat.com>
	 <1348504445.26828.1131.camel@edumazet-glaptop>
	 <1348506011.26828.1195.camel@edumazet-glaptop>
	 <20120924171152.GA26454@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65251 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757238Ab2IXRbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 13:31:22 -0400
Received: by bkcjk13 with SMTP id jk13so1074340bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 10:31:21 -0700 (PDT)
In-Reply-To: <20120924171152.GA26454@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 13:11 -0400, Dave Jones wrote:

> Great, I'll give this a shot.
> 
> Any idea why this only just started triggering ?
> (Ie, do we need this for stable too?)

Seems this is a very old bug.

I guess your trinity tool gets better ?

I used following program to trigger the bug :

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
	int on = 1;
	struct sockaddr_in addr;
	int raw_sock = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);

	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(0x7f000001);
	addr.sin_port = 123;
	connect(raw_sock, (struct sockaddr *)&addr, sizeof(addr));
	setsockopt(raw_sock, SOL_SOCKET, SO_KEEPALIVE, &on, sizeof(on));
	return 0;
}
