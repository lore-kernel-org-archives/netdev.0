From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/2] rocker: introduce be put/get variants
 and use it when appropriate
Date: Fri, 5 Dec 2014 11:25:47 +0100
Message-ID: <20141205102547.GH1866@nanopsycho.orion>
References: <1417612494-3788-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bAgSji_rt3147Kt8jqyT5_yqBCbKjSLgZVa8xkRc0dndA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CA033CC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Scott Feldman' <sfeldma@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:54020 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaLEKZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 05:25:49 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so924505wiw.13
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 02:25:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA033CC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 05, 2014 at 10:57:43AM CET, David.Laight@ACULAB.COM wrote:
>From: Scott Feldman
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> 
>> On Wed, Dec 3, 2014 at 5:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> > This kills the sparse warnings.
>> >
>> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> > ---
>> > v1->v2:
>> > -no change
>> > ---
>> >  drivers/net/ethernet/rocker/rocker.c | 79 ++++++++++++++++++++++--------------
>> >  1 file changed, 48 insertions(+), 31 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> > index fded127..4b060fb 100644
>> > --- a/drivers/net/ethernet/rocker/rocker.c
>> > +++ b/drivers/net/ethernet/rocker/rocker.c
>> > @@ -648,6 +648,11 @@ static u16 rocker_tlv_get_u16(const struct rocker_tlv *tlv)
>> >         return *(u16 *) rocker_tlv_data(tlv);
>> >  }
>> >
>> > +static __be16 rocker_tlv_get_be16(const struct rocker_tlv *tlv)
>> > +{
>> > +       return *(__be16 *) rocker_tlv_data(tlv);
>> > +}
>
>*(int_type *)foo always rings alarm bells.....
>
>That looks dubious on systems where misaligned transfers fault.


This is common use:

for example nla_get_be16

but when you grep kernel, you see many more.

Also, rocker has all accesses like these aligned.

>
>	David
>
