From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Off-by-one bug at unix_mkname ?
Date: Mon, 28 Mar 2005 17:48:39 +0900 (JST)
Message-ID: <20050328.174839.21159646.yoshfuji@linux-ipv6.org>
References: <200503281700.HHE91205.FtVLOStGOSPMYJFMN@I-love.sakura.ne.jp>
	<20050328.172108.30349253.yoshfuji@linux-ipv6.org>
	<20050328.173938.26746686.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	from-linux-kernel@I-love.sakura.ne.jp, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261347AbVC1Iqn@vger.kernel.org>
To: davem@davemloft.net
In-Reply-To: <20050328.173938.26746686.yoshfuji@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20050328.173938.26746686.yoshfuji@linux-ipv6.org> (at Mon, 28 Mar 2005 17:39:38 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> So, I'd suggest to put the comment back to 2.4/2.6 instead.
> (Note: net/socket.c refers this around MAX_SOCK_ADDR definition.)
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Oops, sorry, I made a mistake when I did copy-n-paste...

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/unix/af_unix.c 1.73 vs edited =====
--- 1.73/net/unix/af_unix.c	2005-03-10 13:42:53 +09:00
+++ edited/net/unix/af_unix.c	2005-03-28 17:45:26 +09:00
@@ -188,6 +188,14 @@
 	if (!sunaddr || sunaddr->sun_family != AF_UNIX)
 		return -EINVAL;
 	if (sunaddr->sun_path[0]) {
+		/*
+		 *	This may look like an off by one error but it is
+		 *	a bit more subtle. 108 is the longest valid AF_UNIX
+		 *	path for a binding. sun_path[108] doesnt as such
+		 *	exist. However in kernel space we are guaranteed that
+		 *	it is a valid memory location in our kernel
+		 *	address buffer.
+		 */
 		((char *)sunaddr)[len]=0;
 		len = strlen(sunaddr->sun_path)+1+sizeof(short);
 		return len;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
