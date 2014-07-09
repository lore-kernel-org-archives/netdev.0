From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] dp83640: Adjust ptp event timestamps
Date: Wed, 9 Jul 2014 19:41:49 +0200
Message-ID: <20140709174149.GA3859@localhost.localdomain>
References: <1404901343-19445-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37700 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291AbaGIRmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 13:42:10 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so902249wiv.13
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 10:42:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404901343-19445-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2014 at 12:22:23PM +0200, Stefan S=F8rensen wrote:
> From the dp86340 Software Development Guide:
>   Event timestamp values should be adjusted by 3*reference clock peri=
od +
>   11 ns =3D 35 ns to compensate for input path and synchronization de=
lays.
>=20
> So subtract 35ns from event timestamps.

I have avoided adding this kind of thing into drivers because I think
people will want to make the correction in the delayAsymmetry field of
their user space stack. After all, this is exactly what that value is
supposed to cover.

Some parts have fixed delays (or at least they claim to) and some have
variable delays that can depend on link speed or other factors. So my
gut feeling tells me to be consistent and leave all such corrections
out, because in that way the end user will not have to research
whether a particular driver is "pre-correcting" or not.

Thanks,
Richard
