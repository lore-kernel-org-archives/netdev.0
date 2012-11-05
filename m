From: Jan Synacek <jsynacek@redhat.com>
Subject: Re: ping -f is broken in iputils 20121011
Date: Mon, 05 Nov 2012 10:17:19 +0100
Message-ID: <5097841F.2050905@redhat.com>
References: <20121030205249.GA2817@mail> <1TTUJN-000MzR-Tp@internal.tormail.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090401010203000903050102"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832Ab2KEJRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2012 04:17:22 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qA59HMBZ026376
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2012 04:17:22 -0500
Received: from dhcp-24-219.brq.redhat.com (dhcp-24-219.brq.redhat.com [10.34.24.219])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id qA59HKKN016009
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2012 04:17:21 -0500
In-Reply-To: <1TTUJN-000MzR-Tp@internal.tormail.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090401010203000903050102
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 10/31/2012 10:11 AM, Mohammad Alsaleh wrote:
> On Tue, Oct 30, 2012 at 11:52:49PM +0300, Mohammad Alsaleh wrote:
>> As explained in this bug report(1). ping -f seems to be broken in
>> iputils 20121011.
>>
>> (1) https://bugs.archlinux.org/task/32306
> 
> Bisected to commit 8feb586c4c6df32badb159947ed233898891aecd
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Can you please try the attached patch?

-- 
Jan Synacek
Software Engineer, BaseOS team Brno, Red Hat

--------------090401010203000903050102
Content-Type: text/x-patch;
 name="flood.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="flood.patch"

--- iputils-s20121011/ping_common.h	2012-11-05 10:07:40.065281888 +0100
+++ iputils-s20121011-new/ping_common.h	2012-11-05 10:07:22.001268362 +0100
@@ -141,7 +141,7 @@ static inline void write_stdout(const ch
 	do {
 		cc = write(STDOUT_FILENO, str + o, len - o);
 		o += cc;
-	} while (len >= o || cc < 0);
+	} while (len > o || cc < 0);
 }
 
 /*
--- iputils-s20121011/ping_common.c	2012-11-05 10:07:40.066281889 +0100
+++ iputils-s20121011-new/ping_common.c	2012-11-05 10:07:22.007268368 +0100
@@ -776,7 +776,7 @@ restamp:
 		if (!csfailed)
 			write_stdout("\b \b", 3);
 		else
-			write_stdout("\bC", 1);
+			write_stdout("\bC", 2);
 	} else {
 		int i;
 		__u8 *cp, *dp;

--------------090401010203000903050102--
