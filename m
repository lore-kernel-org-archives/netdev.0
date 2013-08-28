From: Sinan Akpolat <sinan@linkas.com.tr>
Subject: Re: A question about include/linux/socket.h
Date: Wed, 28 Aug 2013 17:35:58 +0300
Message-ID: <521E0ACE.8030502@linkas.com.tr>
References: <521DFEF9.5040701@linkas.com.tr> <1377700055.2264.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:63788 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab3H1OgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 10:36:08 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so3004040eae.37
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 07:36:06 -0700 (PDT)
In-Reply-To: <1377700055.2264.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

28.8.2013 17:27 tarihinde, Ben Hutchings yazd=C4=B1:
> On Wed, 2013-08-28 at 16:45 +0300, Sinan Akpolat wrote:
>> Hi,
>>
>> I am writing CAN bus userspace code and I get a compiler error stati=
ng
>> "sa_family_t is not defined" for "include/linux/can.h". sa_family_t =
is
>> defined in include/linux/socket.h but it is not carried to userspace
>> kernel headers.
>>
>>    When I searched about it I saw that a similar problem in
>> include/linux/netlink.h and include/linux/socket.h is fixed by the p=
atch:
>>
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/comm=
it/include?id=3D6602a4baf4d1a73cc4685a39ef859e1c5ddf654c.
> You probably want commit bcb949b8847655516ba499ca75cd8529f167e360, wh=
ich
> fixed include/linux/can.h.
Yeah, that's the one. Thank you very much, I couldn't find it using cgi=
t=20
interface in git.kernel.org.
>
>> I also read about UAPI but I can't use newer kernels.
>>
>> I searched the kernel git repo but couldn't find a similar patch for
>> can.h. When you search for "sa_family_t" in include/linux directory =
you
>> can see it is used in more than 10 files and I guess none of those f=
iles
>> will compile since they won't be able to find typedef sa_family_t (j=
ust
>> like can.h).
>>
>> So my question is:
>> - Does anyone remember a patch fixing this issue?
>> - Should the typedef sa_family_t moved to userspace kernel headers? =
Or
>> should structs containing sa_family_t type variables moved away from
>> user space?
> No, sa_family_t is normally defined by the C library headers.  But
> kernel headers generally don't include those (for good reasons).  So
> kernel headers should instead define and use __kernel_sa_family_t, an=
d
> that's what they do now (mostly).
>
> Ben.
Thanks for the info.
>
>> I have been using the file manually defining sa_family_t but I wante=
d to
>> ask. I am using kernel version 2.6.37 but I guess can.h file was
>> unchanged until 3.5.
