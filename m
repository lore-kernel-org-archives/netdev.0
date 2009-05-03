From: Rahul Murmuria <rahul@murmuria.in>
Subject: Kernel crashes while calling sock->ops->connect()
Date: Sun, 3 May 2009 19:37:36 -0400
Message-ID: <9511f83e0905031637p73dbc673yb6eedce743c27269@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "J.R. Mauro" <jrm8005@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:24030 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947AbZECXhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 19:37:36 -0400
Received: by yx-out-2324.google.com with SMTP id 3so2032660yxj.1
        for <netdev@vger.kernel.org>; Sun, 03 May 2009 16:37:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
I have been writing a /net virtual filesystem for Linux Kernel[1].

Currently, I am just trying to wrap around BSD Socket in kernel-space.
That involves me using sock_create and sock->ops->connect. This
commit[2] shows pretty much everything that I am working with.

In the function int socknet_connect(), I am creating a socket and
connecting to the ip:port provided from a synthetic file. The problem
is with:
ret = sock->ops->connect(sock, (struct sockaddr *)&addr, sizeof(addr),
sock->file->f_flags);

If I comment the above line, all is fine, but as soon as I use this
function, the kernel crashes in run-time. i.e. in my case, when I say
echo "connect 92.243.0.230:80" > /net/tcp/0/ctl

I have checked ML Archives. Someone suggested checking if the char *ip
does not end in \n or \r. I have also checked for other
implementations in the kernel to see if I am setting the values for
"struct sockaddr_in addr" correctly. I put the sock_create and
ops->connect in the same function to try and avoid errors with struct
socket *sock not being passed around correctly. The problems still
prevail.
So far, no luck.

Can anyone suggest what other things could go wrong? Or maybe look
into my code if you would be kind enough!

[1] http://slashnet.wordpress.com/
[2] http://hg.glendix.org/glendix/rev/31c5adbe25aa


Best Regards,
-- 
Rahul Murmuria
