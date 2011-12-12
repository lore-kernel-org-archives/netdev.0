From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH] kref: add function for reading kref value
Date: Mon, 12 Dec 2011 17:39:12 +0200
Message-ID: <CAEnQRZCZdPw9eWVmdvhtF7KCQkYpLMrkhv5qd5xYckxWksN+0w@mail.gmail.com>
References: <1323693892-11570-1-git-send-email-dbaluta@ixiacom.com>
	<20111212150255.GA7506@kroah.com>
	<CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
	<1323703934.1765.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, adobriyan@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:62322 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab1LLPjN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 10:39:13 -0500
In-Reply-To: <1323703934.1765.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2011 at 5:32 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 12 d=E9cembre 2011 =E0 17:21 +0200, Daniel Baluta a =E9crit =
:
>> On Mon, Dec 12, 2011 at 5:02 PM, Greg KH <greg@kroah.com> wrote:
>> > On Mon, Dec 12, 2011 at 02:44:52PM +0200, Daniel Baluta wrote:
>> >> We can easily get kref refcount value by accesing
>> >> kref->refcount but it is better to have a function
>> >> for this.
>> >
>> > No, you should NEVER need the value of the kref, if you do, you ar=
e
>> > doing something wrong.
>> >
>> > What code needs this patch?
>>
>> I plan to replace raw refcount patterns from net/ with kref, and
>> I have noticed that there are some parts of code who need access
>> to kref->refcount value.
>>
>> e.g:
>>
>> core/neighbour.c:152: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_rea=
d(&n->refcnt) =3D=3D 1 &&
>> core/neighbour.c:801: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_rea=
d(&n->refcnt) =3D=3D 1 &&
>> sched/cls_u32.c:459: =A0if (ht->refcnt =3D=3D 1) {
>>
>
> Well, its not a good idea.
>
> kref adds nothing here.
>

Ok, for the moment it seems to be a bad idea. But my intention is
to integrate kref to networking code, and then to write a general
debugging tool for refs.

Tracking down reference count problems is hard, and this tool can
really help everyone.

thanks,
Daniel.
