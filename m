From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/3] ptp: Allow reassigning calibration pin
 function
Date: Thu, 26 Jun 2014 16:57:20 +0200
Message-ID: <20140626145720.GB10999@netboy>
References: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
 <1403699851-11178-2-git-send-email-stefan.sorensen@spectralink.com>
 <20140626052144.GB4537@netboy>
 <CABkLOboZDJr8tr5JpaUijuNcJ7j7L8nMU33TC0WMn4iir-qVAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:32870 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755626AbaFZO5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 10:57:33 -0400
Received: by mail-we0-f177.google.com with SMTP id u56so3733735wes.8
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 07:57:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CABkLOboZDJr8tr5JpaUijuNcJ7j7L8nMU33TC0WMn4iir-qVAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2014 at 08:14:58AM +0200, Christian Riesch wrote:
> On Thu, Jun 26, 2014 at 7:21 AM, Richard Cochran <richardcochran@gmail.com> wrote:
> > Reassigning the calibration function never makes sense, because it is
> > only used in the driver probe method.
> 
> Yes, indeed, but isn't that a bug? I think the calibration should be
> done again whenever the clock is loaded with a new value, i.e. in
> ptp_dp83640_settime. See section 3.1 in [1]: "All subsequent settings
> should use a step
> adjustment or temporary rate adjustment, which should occur at each
> PHY without introducing any error." This means, whenever we do
> something else (directly write to the clock register), we must
> recalibrate.

When we write the time, we use the broadcast address, and so the PHYs
receive the data at exactly the same time on the MDIO bus. But maybe
they would still need a new, fine calibration. Can you test this?

(I don't have a board with two phys.)

Thanks,
Richard
