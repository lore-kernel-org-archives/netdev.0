From: "SANGTAE HA" <sangtae.ha@gmail.com>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Sat, 12 May 2007 12:45:53 -0400
Message-ID: <649aecc70705120945q58ae79c9r8ff2dc5557658d1e@mail.gmail.com>
References: <20070509023131.70e2cc45.billfink@mindspring.com>
	 <20070510113215.f5ff2d34.billfink@mindspring.com>
	 <2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu>
	 <20070510.133522.99205764.davem@davemloft.net>
	 <20070510134547.7ec30308@freepuppy>
	 <002301c79345$c45ffd00$4a580e98@ncsu2cc0c3fa00>
	 <20070512120739.371ada4f.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_162132_26405071.1178988353382"
Cc: "Injong Rhee" <rhee@eos.ncsu.edu>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, rhee@ncsu.edu,
	netdev@vger.kernel.org
To: "Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:24866 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbXELQpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 12:45:54 -0400
Received: by nz-out-0506.google.com with SMTP id o1so1342410nzf
        for <netdev@vger.kernel.org>; Sat, 12 May 2007 09:45:53 -0700 (PDT)
In-Reply-To: <20070512120739.371ada4f.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_162132_26405071.1178988353382
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Bill,

This is the small patch that has been applied to 2.6.22.
Also, there is "limited slow start", which is an experimental RFC
(RFC3742), to surmount this large increase during slow start.
But, your kernel might not have this. Please check there is a sysctl
variable "tcp_max_ssthresh".

Thanks,
Sangtae


On 5/12/07, Bill Fink <billfink@mindspring.com> wrote:
> On Thu, 10 May 2007, Injong Rhee wrote:
>
> > Oops. I thought Bill was using 2.6.20 instead of 2.6.22 which should contain
> > our latest update.
>
> I am using 2.6.20.7.
>
> > Regarding slow start behavior, the latest version should not change though.
> > I think it would be ok to change the slow start of bic and cubic to the
> > default slow start. But what we observed is that when BDP is large,
> > increasing cwnd by two times is really an overkill. consider increasing from
> > 1024 into 2048 packets..maybe the target is somewhere between them. We have
> > potentially a large number of packets flushed into the network. That was the
> > original motivation to change slow start from the default into a more gentle
> > version. But I see the point that Bill is raising. We are working on
> > improving this behavior in our lab. We will get back to this topic in a
> > couple of weeks after we finish our testing and produce a patch.
>
> Is it feasible to replace the version of cubic in 2.6.20.7 with the
> new 2.1 version of cubic without changing the rest of the kernel, or
> are there kernel changes/dependencies that would prevent that?
>
> I've tried building and running a 2.6.21-git13 kernel, but am having
> some difficulties.  I will be away the rest of the weekend so won't be
> able to get back to this until Monday.
>
>                                                 -Bill
>
> P.S.  When getting into the the 10 Gbps range, I'm not sure there's
>       any way to avoid the types of large increases during "slow start"
>       that you mention, if you want to achieve those kinds of data
>       rates.
>
>
>
> > ----- Original Message -----
> > From: "Stephen Hemminger" <shemminger@linux-foundation.org>
> > To: "David Miller" <davem@davemloft.net>
> > Cc: <rhee@ncsu.edu>; <billfink@mindspring.com>; <sangtae.ha@gmail.com>;
> > <netdev@vger.kernel.org>
> > Sent: Thursday, May 10, 2007 4:45 PM
> > Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
> >
> >
> > > On Thu, 10 May 2007 13:35:22 -0700 (PDT)
> > > David Miller <davem@davemloft.net> wrote:
> > >
> > >> From: rhee@ncsu.edu
> > >> Date: Thu, 10 May 2007 14:39:25 -0400 (EDT)
> > >>
> > >> >
> > >> > Bill,
> > >> > Could you test with the lastest version of CUBIC? this is not the
> > >> > latest
> > >> > version of it you tested.
> > >>
> > >> Rhee-sangsang-nim, it might be a lot easier for people if you provide
> > >> a patch against the current tree for users to test instead of
> > >> constantly pointing them to your web site.
> > >> -
> > >
> > > The 2.6.22 version should have the latest version, that I know of.
> > > There was small patch from 2.6.21 that went in.
>

------=_Part_162132_26405071.1178988353382
Content-Type: application/octet-stream; name=tcp_cubic-2.6.20.3.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f1m22f1u
Content-Disposition: attachment; filename="tcp_cubic-2.6.20.3.patch"

LS0tIG5ldC9pcHY0L3RjcF9jdWJpYy5jLm9sZAkyMDA3LTAzLTIyIDE0OjA4OjU2LjAwMDAwMDAw
MCAtMDQwMAorKysgbmV0L2lwdjQvdGNwX2N1YmljLmMJMjAwNy0wMy0yMiAyMzo0NTo0MS4wMDAw
MDAwMDAgLTA0MDAKQEAgLTEsNSArMSw1IEBACiAvKgotICogVENQIENVQklDOiBCaW5hcnkgSW5j
cmVhc2UgQ29uZ2VzdGlvbiBjb250cm9sIGZvciBUQ1AgdjIuMAorICogVENQIENVQklDOiBCaW5h
cnkgSW5jcmVhc2UgQ29uZ2VzdGlvbiBjb250cm9sIGZvciBUQ1AgdjIuMQogICoKICAqIFRoaXMg
aXMgZnJvbSB0aGUgaW1wbGVtZW50YXRpb24gb2YgQ1VCSUMgVENQIGluCiAgKiBJbmpvbmcgUmhl
ZSwgTGlzb25nIFh1LgpAQCAtMjE1LDcgKzIxNSw5IEBAIHN0YXRpYyBpbmxpbmUgdm9pZCBiaWN0
Y3BfdXBkYXRlKHN0cnVjdCAKIAlpZiAoY2EtPmRlbGF5X21pbiA+IDApIHsKIAkJLyogbWF4IGlu
Y3JlbWVudCA9IFNtYXggKiBydHQgLyAwLjEgICovCiAJCW1pbl9jbnQgPSAoY3duZCAqIEhaICog
OCkvKDEwICogbWF4X2luY3JlbWVudCAqIGNhLT5kZWxheV9taW4pOwotCQlpZiAoY2EtPmNudCA8
IG1pbl9jbnQpCisKKwkJLyogdXNlIGNvbmNhdmUgZ3Jvd3RoIHdoZW4gdGhlIHRhcmdldCBpcyBh
Ym92ZSB0aGUgb3JpZ2luICovCisJCWlmIChjYS0+Y250IDwgbWluX2NudCAmJiB0ID49IGNhLT5i
aWNfSykKIAkJCWNhLT5jbnQgPSBtaW5fY250OwogCX0KIApAQCAtNDAxLDQgKzQwMyw0IEBAIG1v
ZHVsZV9leGl0KGN1YmljdGNwX3VucmVnaXN0ZXIpOwogTU9EVUxFX0FVVEhPUigiU2FuZ3RhZSBI
YSwgU3RlcGhlbiBIZW1taW5nZXIiKTsKIE1PRFVMRV9MSUNFTlNFKCJHUEwiKTsKIE1PRFVMRV9E
RVNDUklQVElPTigiQ1VCSUMgVENQIik7Ci1NT0RVTEVfVkVSU0lPTigiMi4wIik7CitNT0RVTEVf
VkVSU0lPTigiMi4xIik7
------=_Part_162132_26405071.1178988353382--
