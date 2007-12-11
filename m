From: Kevin Wilson <kevin.wilson@comtrol.com>
Subject: sk_prot->sendmsg(...) giving me a kernel oops on kernels past 2.6.20
Date: Tue, 11 Dec 2007 16:51:03 -0600
Message-ID: <475F1457.6080405@comtrol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:57273
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751993AbXLKXCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 18:02:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've searched everywhere (including this list) for a report but couldn't
find anything that can tell me what implementation step(s) I am missing.
Essentially all the kernels past 2.6.20 gives me a kernel oops on the
sendmsg code.

I know the sk_buff changes worked things over quite a bit but I have (or
thought I did) those changes accounted for in our driver. Are there any
specific implementation changes we need to add that we didn't need prior
before we now use sendmsg()? Below is the general gist of the code I am
executing, any pointers to what I am missing would be very welcome.

Thanks a bunch.

Kevin

***************************************
done in userland and passed via ioctl:
***************************************

sk = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

tcp_params.boxid = boxIndex;
tcp_params.sk = sk;
tcp_params.rbuf = malloc(4096);
tcp_params.rbuf_size = 4096;
tcp_params.wbuf = malloc(1460);
tcp_params.wbuf_size = 1460;

rc = ioctl(fd, SI_SET_TCP, &tcp_params);

***************************************
done in kernel space:
***************************************

struct tcp_sock *tp;
struct sock *mysock;

tp = sockfd_lookup(tcp_params.sk, &i);

mysock = tp->sk;

mysock->sk_prot->sendmsg(...);	<-- OOPS HERE

