From: matt mooney <mfmooney@gmail.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Sat, 7 May 2011 12:35:17 -0700
Message-ID: <BANLkTimKs39m_htMFEygR+3Bfu7Butc-zQ@mail.gmail.com>
References: <20110507012717.GA15854@x61.tchesoft.com>
	<1304733100.11874.33.camel@Joe-Laptop>
	<20110507173141.GA4204@x61.tchesoft.com>
	<1304791360.1738.6.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: aquini@linux.com, kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53354 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973Ab1EGTfT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 15:35:19 -0400
In-Reply-To: <1304791360.1738.6.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 7, 2011 at 11:02 AM, Joe Perches <joe@perches.com> wrote:
> On Sat, 2011-05-07 at 14:31 -0300, Rafael Aquini wrote:
>> To exemplify my point, I'll taking that very =A0__ad_timer_to_ticks(=
) as an example:
>> static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
>> {
>> =A0 =A0 =A0 =A0 u16 retval =3D 0;
>>
>> =A0 =A0 =A0 =A0 switch (timer_type) {
>> =A0 =A0 =A0 =A0 case AD_CURRENT_WHILE_TIMER: =A0 =A0/* for rx machin=
e usage */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (par)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D (AD_SHORT=
_TIMEOUT_TIME*ad_ticks_per_sec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D (AD_LONG_=
TIMEOUT_TIME*ad_ticks_per_sec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 case AD_ACTOR_CHURN_TIMER: =A0 =A0 =A0/* for local c=
hurn machine */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D (AD_CHURN_DETECTION_TIME*=
ad_ticks_per_sec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 case AD_PERIODIC_TIMER: =A0 =A0 =A0 =A0 /* for perio=
dic machine */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D (par*ad_ticks_per_sec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 case AD_PARTNER_CHURN_TIMER: =A0 =A0/* for remote ch=
urn machine */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D (AD_CHURN_DETECTION_TIME*=
ad_ticks_per_sec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 case AD_WAIT_WHILE_TIMER: =A0 =A0 =A0 /* for selecti=
on machine */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D (AD_AGGREGATE_WAIT_TIME*a=
d_ticks_per_sec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 return retval;
>> }
>>
>> If, for some unknown reason timer_type receives an 'alien' value, an=
d
>> we were
>> using retval uninitialized, this function, as it is, would return an
>> unpredictable value to its caller. Unless we have the switch block
>> re-factored, we cannot leave retval uninitialized. So, it's not just=
 a
>> matter of leaving the variable uninitialized, or initialize it just =
to
>> get rid of a compiler warning. That's why those comments are not
>> helpful anyway.
>
> I'd write this not using a retval variable at all as:

But isn't the preferred style to have a single exit point?

> =A0 =A0 =A0 =A0switch (timer_type) {
> =A0 =A0 =A0 =A0case AD_CURRENT_WHILE_TIMER: =A0 =A0/* for rx machine =
usage */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (par)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return AD_SHORT_TIMEOU=
T_TIME * ad_ticks_per_sec;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return AD_LONG_TIMEOUT_TIME * ad_ticks=
_per_sec;
> =A0 =A0 =A0 =A0case AD_ACTOR_CHURN_TIMER: =A0 =A0 =A0/* for local chu=
rn machine */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return AD_CHURN_DETECTION_TIME * ad_ti=
cks_per_sec;
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0WARN(1, "Invalid timer type: %u\n", timer_type)
> =A0 =A0 =A0 =A0return 0;
> }
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-jani=
tors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
GPG-Key: 9AFE00EA
