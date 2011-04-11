From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: extending feature word.
Date: Mon, 11 Apr 2011 12:16:45 -0700
Message-ID: <BANLkTik3HaqDMUwCXWRiyiunFXeuXOJA4g@mail.gmail.com>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	<20110408100535.GB10565@rere.qmqm.pl>
	<BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com>
	<20110410101954.GA23753@rere.qmqm.pl>
	<BANLkTimFzTGKmhfRxzEUt_LwrnhAaetU5Q@mail.gmail.com>
	<20110411115459.13ac3c73@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:5306 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836Ab1DKTQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 15:16:49 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3BJGm40030007
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 12:16:48 -0700
Received: from bwz10 (bwz10.prod.google.com [10.188.26.10])
	by kpbe15.cbf.corp.google.com with ESMTP id p3BJGkUG006347
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 12:16:47 -0700
Received: by bwz10 with SMTP id 10so5201885bwz.38
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 12:16:45 -0700 (PDT)
In-Reply-To: <20110411115459.13ac3c73@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 11:54 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 11 Apr 2011 11:45:05 -0700
> Mahesh Bandewar <maheshb@google.com> wrote:
>
>> >> That is right! making it an array doesn't really buy us anything
>> >> unless there is a uniform way of managing all the bits spread across
>> >> multiple words inside that array. This was the reason why I have
>> >> changed that array into a bitmap in the patch that I have posted
>> >> earlier. This way the upper limit (currently only 32 bits) will be
>> >> removed and we'll have a long term solution. There will be little bit
>> >> of work involved but 'doing-things-right' has cost associated.
>> >
>> > I really don't like the bitmap idea. It multiplies the amount of code
>> > needed to manipulate multiple bits at once --- and that's a common
>> > thing for drivers to do. Almost every driver that needs ndo_fix_features
>> > will clear sets --- checkumming set, TSO set, all TX offloads set, ...
>> >
>> Should the added code be of any concern? If that is happening in the
>> control-path and does not affect the data-path as such; those added
>> instructions is a cost of added flexibility to we got through bitmap.
>> If performance is not at risk then that shouldn't be a problem.
>
> Just to be dense... What is wrong with just using u64?
>
I have already suggested that in this thread. With this theoretically
you removing one limit and imposing another and that's why I said it
would be a mid-term solution. But again by the time all 64 bits are
gone (got used), we may have u128 available.

> --
>
