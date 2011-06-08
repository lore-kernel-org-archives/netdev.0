From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Tue, 7 Jun 2011 23:55:10 -0700
Message-ID: <BANLkTi=-M=NusYU0U66cbvYeu=560U+xXQ@mail.gmail.com>
References: <20110606035808.GA28858@redhat.com> <20110605.221537.899061768025493519.davem@davemloft.net>
 <20110606153253.GB30665@redhat.com> <20110606.122059.261517215690508151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: mst@redhat.com, linux-netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:8876 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab1FHGzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 02:55:43 -0400
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p586tZUJ012053
	for <netdev@vger.kernel.org>; Tue, 7 Jun 2011 23:55:36 -0700
Received: from bwz13 (bwz13.prod.google.com [10.188.26.13])
	by kpbe20.cbf.corp.google.com with ESMTP id p586tUta007065
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 7 Jun 2011 23:55:34 -0700
Received: by bwz13 with SMTP id 13so166288bwz.3
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 23:55:30 -0700 (PDT)
In-Reply-To: <20110606.122059.261517215690508151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 6, 2011 at 12:20 PM, David Miller <davem@davemloft.net> wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Mon, 6 Jun 2011 18:32:53 +0300
>
>> On Sun, Jun 05, 2011 at 10:15:37PM -0700, David Miller wrote:
>>> Since the GSO accessors deal with mutliple bits, you can create
>>> special GSO specific interfaces to manipulate them.
>>
>> Yes but it's not just GSO.
>> It's anything that includes more than 1 feature.
>> Examples:
>> NETIF_F_ALL_CSUM
>> NETIF_F_ALL_TX_OFFLOADS
>> NETIF_F_V6_CSUM
>> NETIF_F_SOFT_FEATURES
>>
>> etc
>>
>> Creating many accessors for each will need a lot
>> of code duplication ...
>
> Yet this is something you must resolve in order to change the feature
> bit implementation.
>
> Whether this issue is difficult or not to address, it has to be done
> either way.
>

I agree that the cleanup is not really necessary to the feature
extension as such but this along with the other patch that I have
posted is the beginning of that work. It's definitely not complete and
also not as simple as it sounds / feels because of these constants
defined which are "or-ed" flag values (listed above). I think it will
be nice to get this done in as little code as possible, but I think
that should be the constraint.

In these two patches I have created separate header file
"netdev_features.h" where everything related to "features" should
reside including all these accessor macros / functions.

--mahesh..
