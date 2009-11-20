From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 15:53:43 -0800
Message-ID: <65634d660911201553i2fbd87d9yffe9edc8bedc9019@mail.gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	 <20091120154046.67252d23@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:31246 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbZKTXxn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 18:53:43 -0500
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id nAKNrkPa027079
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 23:53:48 GMT
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz33.hot.corp.google.com with ESMTP id nAKNrGXt018331
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:53:44 -0800
Received: by pwi9 with SMTP id 9so2762289pwi.6
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:53:44 -0800 (PST)
In-Reply-To: <20091120154046.67252d23@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 3:40 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 20 Nov 2009 15:28:58 -0800
> Tom Herbert <therbert@google.com> wrote:
>
>> +static char *get_token(const char **cp, size_t *len)
>> +{
>> + =A0 =A0 const char *bp =3D *cp;
>> + =A0 =A0 char *start;
>> +
>> + =A0 =A0 while (isspace(*bp))
>> + =A0 =A0 =A0 =A0 =A0 =A0 bp++;
>> +
>> + =A0 =A0 start =3D (char *)bp;
>> + =A0 =A0 while (!isspace(*bp) && *bp !=3D '\0')
>> + =A0 =A0 =A0 =A0 =A0 =A0 bp++;
>> +
>> + =A0 =A0 if (start !=3D bp)
>> + =A0 =A0 =A0 =A0 =A0 =A0 *len =3D bp - start;
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 start =3D NULL;
>> +
>> + =A0 =A0 *cp =3D bp;
>> + =A0 =A0 return start;
>> +}
>
>
> Sysfs is intentionally one value per file. If you need multiple
> values, then it is the wrong interface.
>

What would be a better interface?

> --
>
