From: "Andrew Brampton" <andrew@bramp.freeserve.co.uk>
Subject: sock_get_timestamp() ktime_to_timeval returns -2?
Date: Fri, 4 Apr 2008 19:38:42 +0100
Message-ID: <013101c89683$1bd00940$0a00a8c0@Andrew>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ptb-relay02.plus.net ([212.159.14.213]:46798 "EHLO
	ptb-relay02.plus.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757328AbYDDSik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 14:38:40 -0400
Received: from [80.229.232.206] (helo=Andrew)
	 by ptb-relay02.plus.net with smtp (Exim) id 1Jhqo9-0001hx-SZ
	for netdev@vger.kernel.org; Fri, 04 Apr 2008 19:38:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm using the following piece of code to record the received time of my 
packets.

struct timeval tv = {0,0};
if ( ioctl(s, SIOCGSTAMP, &tv) )
   return 0;

When I use UDP this is all great, but when I use TCP this stops working. I 
have since found out that I can't use this for TCP packets[1], but the 
reason I'm writing this email is because ioctl returns zero when using TCP 
and tv has a odd value in it. tv.tv_sec = -2, and tv.tv_usec = 999999.

Now I assume -2 is some kind of error code, so I dug into the linux code to 
try and figure out what it means. The ioctl eventually calls 
sock_get_timestamp() which in turn calls ktime_to_timeval. I can see in 
sock_get_timestamp() that tv_sec is compared to -1 and ioctl returns an 
error, however I can not find where tv_sec is set to -2. If -2 is another 
error code then it should be checked inside sock_get_timestamp().

So I'm wondering if this is a bug in the kernel somewhere, or should I just 
expect ioctl to fail yet return 0? I have not included a test app, but if 
you want I'll be happy to code a short app to show this problem, but the 
critital lines are the ioctl call and that a TCP socket is used. This occurs 
on both the 2.6.22-3-amd64 kernel as well as on 2.6.24.

Thanks
Andrew

[1] http://www.ussg.iu.edu/hypermail/linux/kernel/0301.2/1248.html 

