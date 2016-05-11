From: Mark D Rustad <mrustad@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: prevent division by zero if TIMINCA is zero
Date: Tue, 10 May 2016 22:59:47 -0500
Message-ID: <4DFD5422-8197-4699-977E-8DE3624FC198@gmail.com>
References: <1462563711-30350-1-git-send-email-dvlasenk@redhat.com> <5E18E4A4-E10F-46B5-A2F5-FCA10FAA5030@intel.com> <20160510210042.GA19319@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_CB41DDB1-EB25-4165-8394-ED0338998F5F"; protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Mark Rustad <mark.d.rustad@intel.com>,
	Denys Vlasenko <dvlasenk@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33714 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbcEKD7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 23:59:51 -0400
In-Reply-To: <20160510210042.GA19319@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_CB41DDB1-EB25-4165-8394-ED0338998F5F
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Jarod Wilson <jarod@redhat.com> wrote:

> On Fri, May 06, 2016 at 11:43:17PM +0000, Rustad, Mark D wrote:
>> Denys Vlasenko <dvlasenk@redhat.com> wrote:
>>
>>> Users report that under VMWare, er32(TIMINCA) returns zero.
>>> This causes division by zero at init time as follows:
>>>
>>> ==>            incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
>>>                for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
>>>                        /* latch SYSTIMH on read of SYSTIML */
>>>                        systim_next = (cycle_t)er32(SYSTIML);
>>>                        systim_next |= (cycle_t)er32(SYSTIMH) << 32;
>>>
>>>                        time_delta = systim_next - systim;
>>>                        temp = time_delta;
>>> ====>                  rem = do_div(temp, incvalue);
>>>
>>> This change makes kernel survive this, and users report that
>>> NIC does work after this change.
>>>
>>> Since on real hardware incvalue is never zero, this should not affect
>>> real hardware use case.
> ...
>> I seem to recall that this was rejected before because it really is  
>> VMWare's
>> bug and, if they fix it, any existing VMs that use this will just work.
>> Changing the driver will only fix it for vms that install a new driver. I
>> don't object to doing it, it just seems like not the most effective  
>> place to
>> address the issue.
>
> You could also have people who never update VMWare, for whom a kernel
> work-around would be better. I think it'd be best to address it both at
> the driver level and the emulated hardware level, to improve things for
> the most possible users. Those who update neither hypervisor or
> kernel/driver, well, they reap what they sow.

That is a sound argument for doing both. I would expect that there are more  
frozen VM images than host environments, but I can certainly imagine that  
some choose to freeze their host. Of course if everything is frozen there  
is no point at all. :-)

I am on an extended vacation, and don't work on e1000e anyway, so I will  
quit my kibitzing here.

--
Mark Rustad, MRustad@gmail.com

--Apple-Mail=_CB41DDB1-EB25-4165-8394-ED0338998F5F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJXMq4zAAoJEDwO/+eO4+5u4jEP/2TSmMCJQhVik5Uibcty25tz
a3ZgTYvKrQzB3CsVKfPS3dIQiGje6xyPJlMbAWneoM4A0i+uCiTqmmWJPNEBa6K9
1vn/su/Vmj27GmuFxPVyT20qipK3so1F726HPnSfA4jtKhtoAcB2rWXSUOOge67N
b9xjac+gCOK+HQ/SbL32luNn0me73VGFM9FdsbW4wzMpzW2gOMsx4b9pg/TaazsJ
JO2jpm7qy06BnERGv+qZYk0fWP4GgY4lA/EX6qikuLYDZmb4d8SrR9qlpTLKWV7B
R4kYNxjpVJrnCqxif6hKLddCbaO1avMd30dvSz2ugHQWtaiJg/xEV0pZAfogxEHY
eDiI/UemWYdR9DXIGzkji/WSFdGj/0fDxSeYEm7Uw2M68XtEj82VjExV4ve3Hnjn
bqFOHvMBOAbeFB9L4d65KzE2QOUDn9LNsoC5ROO7oRbW18NQ3tS3HsUC46h0+ilo
SUib10EdIUbb2oM81SsQWXslR41e0oGVMgZcXBzP2BJueUfT0HjRPTcYrURQhRq0
LTf9hjRACoSdHH3Y9az7Lljo/u/qGRLU1BCGL1aWj7TLae16RteynybcsJ5RGN8G
xeQINYOWbV4hKD0lzTgS9f/Li9WCqHDQtUfieqobGL5YsgEsj2HYotr9T39Gg8Nx
4OADnTbvs2yYzL4uRdXY
=h/nq
-----END PGP SIGNATURE-----

--Apple-Mail=_CB41DDB1-EB25-4165-8394-ED0338998F5F--
