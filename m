From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH net-next 1/3] ptp: Allow reassigning calibration pin function
Date: Thu, 26 Jun 2014 08:14:58 +0200
Message-ID: <CABkLOboZDJr8tr5JpaUijuNcJ7j7L8nMU33TC0WMn4iir-qVAw@mail.gmail.com>
References: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
	<1403699851-11178-2-git-send-email-stefan.sorensen@spectralink.com>
	<20140626052144.GB4537@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Stefan_S=C3=B8rensen?= <stefan.sorensen@spectralink.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:32771 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315AbaFZGO7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 02:14:59 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so2700208qcv.33
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 23:14:58 -0700 (PDT)
In-Reply-To: <20140626052144.GB4537@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

On Thu, Jun 26, 2014 at 7:21 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Wed, Jun 25, 2014 at 02:37:29PM +0200, Stefan S=C3=B8rensen wrote:
>> The ptp pin function programming does not allow calibration pin to c=
hange
>> function. This is problematic on hardware that uses the default cali=
bration
>> pin for other purposes.
>>
>> Removing this limitation does not impact calibration if userspace do=
es not
>> reprogram the calibration pin.
>
> Reassigning the calibration function never makes sense, because it is
> only used in the driver probe method.

Yes, indeed, but isn't that a bug? I think the calibration should be
done again whenever the clock is loaded with a new value, i.e. in
ptp_dp83640_settime. See section 3.1 in [1]: "All subsequent settings
should use a step
adjustment or temporary rate adjustment, which should occur at each
PHY without introducing any error." This means, whenever we do
something else (directly write to the clock register), we must
recalibrate.

> Clobbering the calibration pin with another function only makes sense
> if the hardware design has exactly one PHY.

Or if the hardware has two PHYs that are not used at the same time. I
have a board that has two DP83640 on the same MII bus, one is used for
optical Ethernet, one for copper. Only one of the PHYs is powered up
at a time, the other one is in power down and MII isolate mode. In
such a case the calibration pin could be used for something else.

Christian
