From: Sinan Akpolat <sinan@linkas.com.tr>
Subject: A question about include/linux/socket.h
Date: Wed, 28 Aug 2013 16:45:29 +0300
Message-ID: <521DFEF9.5040701@linkas.com.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-9; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:48396 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab3H1Npj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 09:45:39 -0400
Received: by mail-bk0-f50.google.com with SMTP id mz11so2155016bkb.23
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 06:45:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am writing CAN bus userspace code and I get a compiler error stating 
"sa_family_t is not defined" for "include/linux/can.h". sa_family_t is 
defined in include/linux/socket.h but it is not carried to userspace 
kernel headers.

  When I searched about it I saw that a similar problem in 
include/linux/netlink.h and include/linux/socket.h is fixed by the patch:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/include?id=6602a4baf4d1a73cc4685a39ef859e1c5ddf654c. 


I also read about UAPI but I can't use newer kernels.

I searched the kernel git repo but couldn't find a similar patch for 
can.h. When you search for "sa_family_t" in include/linux directory you 
can see it is used in more than 10 files and I guess none of those files 
will compile since they won't be able to find typedef sa_family_t (just 
like can.h).

So my question is:
- Does anyone remember a patch fixing this issue?
- Should the typedef sa_family_t moved to userspace kernel headers? Or 
should structs containing sa_family_t type variables moved away from 
user space?

I have been using the file manually defining sa_family_t but I wanted to 
ask. I am using kernel version 2.6.37 but I guess can.h file was 
unchanged until 3.5.

Thanks
