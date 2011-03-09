From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch V2] bonding: fix netpoll in active-backup mode
Date: Wed, 09 Mar 2011 20:34:43 +0800
Message-ID: <4D7773E3.5050708@redhat.com>
References: <1299578336-5888-1-git-send-email-amwang@redhat.com> <20110308212405.GX11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209Ab1CIMfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 07:35:42 -0500
In-Reply-To: <20110308212405.GX11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B403=E6=9C=8809=E6=97=A5 05:24, Andy Gospodarek =E5=
=86=99=E9=81=93:
> On Tue, Mar 08, 2011 at 05:58:56PM +0800, Amerigo Wang wrote:
>> V2: avoid calling slave_diable_netpoll() with write_lock_bh() held.
>>
>> netconsole doesn't work in active-backup mode, because we don't do a=
nything
>> for nic failover in active-backup mode. We should disable netpoll on=
 the
>> failing slave when it is detected down and enable netpoll when it be=
comes
>> the active slave.
>>
>> Tested by ifdown the current active slave and ifup it again for seve=
ral times,
>> netconsole works well.
>>
>> Signed-off-by: WANG Cong<amwang@redhat.com>
>> Cc: Neil Horman<nhorman@tuxdriver.com>
>>
>
> It seems like you are going to a lot of trouble to fix a bug where
> netpoll will not be setup on any interface that is down when enslaved=
=2E
> That seems to be the only path that would not have slave->np setup
> properly at enslavement.
>
> Did you ever try just this?

That was my first thought, but I was over-worried about the failing sla=
ve.
This way should work too. Mind to send it as a normal patch? :)

Thanks!

