From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Patch V2] bonding: fix netpoll in active-backup mode
Date: Fri, 11 Mar 2011 09:35:57 -0500
Message-ID: <20110311143557.GY11864@gospo.rdu.redhat.com>
References: <1299578336-5888-1-git-send-email-amwang@redhat.com> <20110308212405.GX11864@gospo.rdu.redhat.com> <4D7773E3.5050708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, linux-kernel@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D7773E3.5050708@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2011 at 08:34:43PM +0800, Cong Wang wrote:
> =E4=BA=8E 2011=E5=B9=B403=E6=9C=8809=E6=97=A5 05:24, Andy Gospodarek =
=E5=86=99=E9=81=93:
>> On Tue, Mar 08, 2011 at 05:58:56PM +0800, Amerigo Wang wrote:
>>> V2: avoid calling slave_diable_netpoll() with write_lock_bh() held.
>>>
>>> netconsole doesn't work in active-backup mode, because we don't do =
anything
>>> for nic failover in active-backup mode. We should disable netpoll o=
n the
>>> failing slave when it is detected down and enable netpoll when it b=
ecomes
>>> the active slave.
>>>
>>> Tested by ifdown the current active slave and ifup it again for sev=
eral times,
>>> netconsole works well.
>>>
>>> Signed-off-by: WANG Cong<amwang@redhat.com>
>>> Cc: Neil Horman<nhorman@tuxdriver.com>
>>>
>>
>> It seems like you are going to a lot of trouble to fix a bug where
>> netpoll will not be setup on any interface that is down when enslave=
d.
>> That seems to be the only path that would not have slave->np setup
>> properly at enslavement.
>>
>> Did you ever try just this?
>
> That was my first thought, but I was over-worried about the failing s=
lave.
> This way should work too. Mind to send it as a normal patch? :)
>

I'm happy to submit the patch if it works in your environment.

I do not think anyone likes un-tested patches.
