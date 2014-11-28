From: FengYu LeiDian <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH iproute2] ip xfrm: support 64bit kernel and 32bit userspace
Date: Fri, 28 Nov 2014 16:07:40 +0800
Message-ID: <54782D4C.60407@gmail.com>
References: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com> <54781F55.5040603@gmail.com> <CAJFZqHyHaD7+6fqjmsVh_JeDrto5SmN2D6rZkjWa3axfM0+AiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:61010 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaK1IKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 03:10:14 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so6411083pad.29
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 00:10:13 -0800 (PST)
In-Reply-To: <CAJFZqHyHaD7+6fqjmsVh_JeDrto5SmN2D6rZkjWa3axfM0+AiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2014=C4=EA11=D4=C228=C8=D5 15:35, Li RongQing =D0=B4=B5=C0:
> On Fri, Nov 28, 2014 at 3:08 PM, FengYu LeiDian
> <fengyuleidian0615@gmail.com>  wrote:
>> >=D3=DA 2014=C4=EA11=D4=C228=C8=D5 14:58,roy.qing.li@gmail.com  =D0=B4=
=B5=C0:
>>> >>From: Li RongQing<roy.qing.li@gmail.com>
>>> >>
>>> >>The size of struct xfrm_userpolicy_info is 168 bytes for 64bit ke=
rnel, and
>>> >>164 bytes for 32bit userspace because of the different alignment.=
 and lead
>>> >>to "ip xfrm" be unable to work.
>>> >>
>>> >>add a pad in struct xfrm_userpolicy_info, and enable it by set
>>> >>KERNEL_64_USERSPACE_32 to y
>> >
>> >
>> >It's not easy to fix it like this.
>> >
>> >Refer:
>> >http://marc.info/?l=3Dlinux-netdev&m=3D139280143513650&w=3D2
>> >http://thread.gmane.org/gmane.linux.network/157118/focus=3D157122
>> >
> is it be practical to find all structures which has the issue for
> 64bit kernel and 32 bit
> userspace, and conditionally add a pad for them

Apparently struct xfrm_userpolicy_info is not the only one,
you could try to set SA as well, it breaks also...
=46ix those where it hurts, hehe :) Otherwise, the "compat layer"
fix style is good choice.
