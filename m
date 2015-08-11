From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/2] of: fsl/fman: reuse the fixed node parsing code
Date: Tue, 11 Aug 2015 19:00:20 +0300
Message-ID: <55CA1C14.3000202@list.ru>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
 <55C63D3B.5020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	Igal.Liberman@freescale.com,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	madalin.bucur@freescale.com, netdev@vger.kernel.org,
	grant.likely@linaro.org, robh+dt@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C63D3B.5020005@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

08.08.2015 20:32, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> CC'ing Stas,
Hi.

> Le 08/05/15 07:42, Madalin Bucur a =C3=A9crit :
>> The FMan MAC configuration code needs the speed and duplex informati=
on
>> for fixed-link interfaces that is parsed now by the of function
>> of_phy_register_fixed_link(). This parses the fixed-link parameters =
but
>> does not expose to the caller neither the phy_device pointer nor the
>> status struct where it loads the fixed-link params.
I have only barely touched that code, but IMO both things
are by design. There are some API deficiencies, and so, many
drivers still use of_phy_find_device() to circumvent the encapsulation
and get the phy_device pointer, but this is unlikely a good thing
to do. I even proposed some API extensions, but there was no
interest.

>>   By extracting the
>> fixed-link parsing code from of_phy_register_fixed_link() into a
>> separate function the parsed values are made available without chang=
ing
>> the existing API. This change also removes a small redundancy in the
>> previous code calling fixed_phy_register().
Today, the fixed_link is not always fixed.
See for example this patch (already mainlined):
https://lkml.org/lkml/2015/7/20/711
of_phy_is_fixed_link() returns 'true' if you have
managed=3D"in-band-status", and so the SGMII in-band status
can update fixed-link params.

So my question is: why do you even need to know whether
the link is fixed or not? IIRC you can check the phy_device
pointer in the adjust_link callback of of_phy_connect() to get
the current link status values. Why is this not enough for your
task? Maybe the patch description should be updated to include
why the current technique is bad, what is actually fixed by the
change.
I think using the fixed-link DT values directly is not something
to be done. The encapsulation is there for a reason, so maybe
instead we can see what API additions do we need to avoid the
current limitations that force people to use of_phy_find_device()
and other work-arounds.
