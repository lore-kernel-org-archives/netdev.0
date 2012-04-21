From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next 04/14] net: Fix issue with netdev_tx_reset_queue not
 resetting queue from XOFF state
Date: Fri, 20 Apr 2012 23:01:21 -0700
Message-ID: <CA+mtBx-TJAr-cu-vKYq6m2ZQzn1X1vf+_PKUZXDirnKEF67EAw@mail.gmail.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331611432-30109-5-git-send-email-jeffrey.t.kirsher@intel.com>
	<CA+mtBx-BWy=KANgSca9f2vxuu1Km_kPMJbQFa+Nq9q_YYvatBQ@mail.gmail.com>
	<4F91D5A2.2060300@intel.com>
	<CAKgT0UcZZNOH=D5mJDaw3_6femW120ZG0cBc8Nz=-=8h6X17kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, John Fastabend <john.r.fastabend@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:39563 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab2DUGBW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 02:01:22 -0400
Received: by obbta14 with SMTP id ta14so10447330obb.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 23:01:21 -0700 (PDT)
In-Reply-To: <CAKgT0UcZZNOH=D5mJDaw3_6femW120ZG0cBc8Nz=-=8h6X17kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't recall the exact reason now, as John said I think it had to d=
o
> with the ethtool tests not using the same cleanup routine and leaving
> us in a bad state. =A0I am pretty sure there was some path in which
> where the call was didn't work but I do not recall the exact details
> now. =A0Most of the reason for moving it is due to the fact that the
> reset is now also clearing the bit, and from the driver perspective w=
e
> didn't need it in two places. =A0After looking it all over again, I
> suppose this causes a cosmetic issue for the bql "inflight" statistic
> in sysfs since the value will be retained until the interface is
> brought back up with this change. =A0Is that an issue or something th=
at
> can be lived with since the interface isn't active anyway in this
> case?
>
On the surface, it seems cleaner and probably a simpler convention to
clear the state when the buffers are being freed.  If there's a good
reason not to do this for igb, it makes me wonder if this should be
done the same way in other drivers...

Tom
