From: "Jouke Witteveen" <j.witteveen@gmail.com>
Subject: Re: [PATCH] Move if_mii to userspace in mii.h
Date: Wed, 5 Nov 2008 12:14:03 +0100
Message-ID: <3993a4980811050314l303c80ft8b07338a909fc34e@mail.gmail.com>
References: <3993a4980811050142u913819ek5ef7824efce45a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wtarreau@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f17.google.com ([209.85.217.17]:34303 "EHLO
	mail-gx0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592AbYKELVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 06:21:11 -0500
Received: by gxk10 with SMTP id 10so206026gxk.18
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 03:21:09 -0800 (PST)
In-Reply-To: <3993a4980811050142u913819ek5ef7824efce45a1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

Please do not apply the proposed patch. It does, of course, not work,
since the ifreq struct need not exist at the point in the file where I
have put the function.
An (ugly?) way around this would to move the function to the end of the file:
--- excerpt ------
#endif /* __KERNEL__ */
#ifdef _LINUX_IF_H

static inline struct mii_ioctl_data *if_mii(struct ifreq *rq)
{
        return (struct mii_ioctl_data *) &rq->ifr_ifru;
}

#endif /* __LINUX_IF_H */
#endif /* __LINUX_MII_H__ */
--- end of excerpt ------
Based on the looks of it I am not sure whether this is a good idea.

Sorry for the inconvenience,
Jouke Witteveen


On Wed, Nov 5, 2008 at 10:42, Jouke Witteveen <j.witteveen@gmail.com> wrote:
> Dear all,
>
> There is a convenient routine in include/linux/mii.h called if_mii. It
> is, however, kept away from userspace. A patch is attached that moves
> it back to userspace so that it can be included from outside the
> kernel.
>
> Note that the current mii.h in kernel 2.4 does not hide the function.
>
> Regards,
> Jouke Witteveen
>
