From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] tcp: '< 0' test on unsigned
Date: Mon, 02 Mar 2009 13:24:52 +0100
Message-ID: <49ABD014.3010006@gmail.com>
References: <49AAF989.8070000@gmail.com>	<20090302043056.GA16090@gondor.apana.org.au> <20090301.203643.105143832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:48038 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbZCBMY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 07:24:56 -0500
Received: by bwz26 with SMTP id 26so1901293bwz.37
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2009 04:24:53 -0800 (PST)
In-Reply-To: <20090301.203643.105143832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 2 Mar 2009 12:30:56 +0800
> 
>> Roel Kluin <roel.kluin@gmail.com> wrote:
>>> diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
>>> index 25524d4..0b9d63f 100644
>>> --- a/net/ipv4/tcp_probe.c
>>> +++ b/net/ipv4/tcp_probe.c
>>> @@ -167,7 +167,7 @@ static ssize_t tcpprobe_read(struct file *file, char __user *buf,
>>> {
>>>        int error = 0, cnt = 0;
>>>
>>> -       if (!buf || len < 0)
>>> +       if (!buf || (ssize_t)len < 0)
>>>                return -EINVAL;
>>>
>>>        while (cnt < len) {
>> Either cnt needs to be promoted, or you need to limit len to INT_MAX.
> 
> Right, since the positive range of 'size_t' can exceed that of 'int'

like this then?
------------------------------>8-------------8<---------------------------------
promote 'cnt' to size_t, to match 'len'.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 25524d4..59f5b5e 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -165,9 +165,10 @@ static int tcpprobe_sprint(char *tbuf, int n)
 static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 			     size_t len, loff_t *ppos)
 {
-	int error = 0, cnt = 0;
+	int error = 0;
+	size_t cnt = 0;
 
-	if (!buf || len < 0)
+	if (!buf)
 		return -EINVAL;
 
 	while (cnt < len) {
