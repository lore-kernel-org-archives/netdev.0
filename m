From: Takashi Hibi <hibi665@oki.com>
Subject: Kernel 2.4.22 MLD problems
Date: Wed, 10 Dec 2003 15:38:10 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210153810.4ec4639e%hibi665@oki.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

We are testing IPv6 multicast with FreeBSD(kame) router.
The kernel version is 2.4.22. And we are using both MLDv1 and MLDv2.

We apply some patches to fix problems of 2.4.22
- fix MLD v1 compatibility mode checks to allow for extension header
  http://oss.sgi.com/archives/netdev/2003-11/msg00449.html
- MLDv2 MRC timer wrong units [PATCH] 
  http://oss.sgi.com/archives/netdev/2003-11/msg00364.html

But there are still some problems.
[MLDv2]
1. After joining multicast address, MLDv2 listener report isn't issued immediately.
2. After leaving multicast address, MLDv2 listener report is issued, but multicast
   routing doesn't stop. The type of report is ChangeToIncludeMode.
   FreeBSD doesn't seem to stop multicast after receiving it.
[MLDv1]
1. After joining multicast address, MLDv2 listener report(not MLDv1) is issued.
   After receiving MLDv2 query, MLDv1 listener report is issued.
2. After leaving multicast address, MLDv2 listener report is sometimes issued.
   It happens after long communication.

And I have a question about recent patch.
http://www-124.ibm.com/linux/patches/ipv6/2.4.22JUMBO.patch
This patch doesn't include the following patch.
http://oss.sgi.com/archives/netdev/2003-11/msg00364.html
Isn't it necessary?

Regards,
Takashi Hibi
