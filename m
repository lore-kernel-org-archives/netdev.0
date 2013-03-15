From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net,stable-3.8] net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards compatibility
Date: Fri, 15 Mar 2013 08:02:43 +0100
Message-ID: <87ppz14030.fsf@nemi.mork.no>
References: <1363259113-6909-1-git-send-email-bjorn@mork.no>
	<1363324945.3937.144.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41385 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429Ab3COHDA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 03:03:00 -0400
In-Reply-To: <1363324945.3937.144.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Fri, 15 Mar 2013 05:22:25 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> writes:

> On Thu, 2013-03-14 at 12:05 +0100, Bj=C3=B8rn Mork wrote:
>> commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible MBIM de=
vices")
>> introduced a new policy, preferring MBIM for dual NCM/MBIM functions=
 if
>> the cdc_mbim driver was enabled.  This caused a regression for users
>> wanting to use NCM.
>>=20
>> Devices implementing NCM backwards compatibility according to sectio=
n
>> 3.2 of the MBIM v1.0 specification allow either NCM or MBIM on a sin=
gle
>> USB function, using different altsettings.  The cdc_ncm and cdc_mbim
>> drivers will both probe such functions, and must agree on a common
>> policy for selecting either MBIM or NCM.  Until now, this policy has
>> been set at build time based on CONFIG_USB_NET_CDC_MBIM.
>>=20
>> Use a module parameter to set the system policy at runtime, allowing=
 the
>> user to prefer NCM on systems with the cdc_mbim driver.
>>=20
>> Cc: Greg Suarez <gsuarez@smithmicro.com>
>> Cc: Alexey Orishko <alexey.orishko@stericsson.com>
>> Reported-by: Geir Haatveit <nospam@haatveit.nu>
>> Reported-by: Tommi Kyntola <kynde@ts.ray.fi>
>> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D54791
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>> ---
>>=20
>> We now have two users independently reporting this as a 3.8 regressi=
on,
>> so something needs to be done.  I am not sure if adding a new module
>> parameter is acceptable for stable, but this problem is definitely a
>> regression and no other solutions came up in response to my RFC.
>>=20
>> The only real alternative I see for stable, is disabling MBIM suppor=
t
>> on any dual NCM/MBIM function.  Which of course will be a regression
>> for any user wanting MBIM, making it unacceptable.
> [...]
>
> It definitely makes sense for this to be a run-time parameter.  And t=
he
> default seems correct for custom kernels.
>
> For a distribution kernel - at least for Debian, where we can't assum=
e
> kernel and userland are always updated together - I think the
> compile-time default should be false, and the userland package
> (presumably ModemManager?) can install a modprobe.conf file to overri=
de
> that once it can handle MBIM.  We handled KMS transitions in a simila=
r
> way.  I don't know that it's worth having a Kconfig option for that,
> though.

We could consider always defaulting to NCM.  That would remove the
ugliest parts of the code as well.  Should I send a new version with
such a change?

Bundling a modprobe.conf file to enable MBIM with userland tools
supporting it is a great idea, and sounds feasible for custom built
systems as well.

(BTW, if there is any doubt about it, I feel really bad about my recent
request to enable MBIM in Debian, where I wrote "enabling the driver
will not prevent any existing solution from working.".  At the time, I
had not seen any of these dual NCM/MBIM functions and I just didn't
think about the problems such devices would run into. Sorry about
that. I guess I owe you one more...)


Bj=C3=B8rn
