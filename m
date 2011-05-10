From: David Decotigny <decot@google.com>
Subject: Re: [PATCH 2/2] net/dl2k: Don't reconfigure link @100Mbps when
 disabling autoneg @1Gbps
Date: Tue, 10 May 2011 15:14:59 -0700
Message-ID: <BANLkTik5Uc8yRRHoNMENkQNeAnovLYcZjQ@mail.gmail.com>
References: <1304986748-15809-1-git-send-email-decot@google.com>
 <1304986748-15809-3-git-send-email-decot@google.com> <1305053707.2859.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:8160 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab1EJWP2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 18:15:28 -0400
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4AMFRqS032024
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 15:15:27 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by hpaq3.eem.corp.google.com with ESMTP id p4AMETWE031647
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 15:15:22 -0700
Received: by qwa26 with SMTP id 26so5328340qwa.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 15:15:19 -0700 (PDT)
In-Reply-To: <1305053707.2859.57.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Yes, right, I will send the updated patch together with the stmmac
update (if any).

I just hope that changing the netdev_private fields without committing
to hardware and before calling netif_carrier_off() will not create too
much confusion. I don't think so, but I still wish I could test.

Regards,

--
David Decotigny



On Tue, May 10, 2011 at 11:55 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Mon, 2011-05-09 at 17:19 -0700, David Decotigny wrote:
>> The initial version of the driver used to force the link to 100Mbps
>> when auto-negociation was disabled on a 1Gbps link, ignoring the
>> requested link speed. Instead, this change refuses to change anythin=
g
>> when it is asked to configure the link speed at 1Gbps without
>> auto-negociation, but acts as requested in all the other cases.
>>
>> IMPORTANT: Previously, the return value from mii_set_media() was
>> =A0 =A0 =A0 =A0 =A0 =A0ignored. This patch uses it for its own retur=
n value.
>>
>> Tested: module compiling, NOT tested on real hardware.
>> Signed-off-by: David Decotigny <decot@google.com>
> [...]
>
> The changes to validation look fine. =A0However, I noticed that there=
's a
> call to netif_carrier_off() at the top of this function. =A0This mean=
s
> that in the error and shortcut cases, the interface will be left
> disabled! =A0It's an existing bug but might be made slightly worse by=
 this
> change.
>
> Please also move the call to netif_carrier_off() down to the end, jus=
t
> before the call to mii_set_media() which actually alters the link.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
