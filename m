From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: What is SOF_TIMESTAMPING_RX_HARDWARE?
Date: Tue, 4 Mar 2014 11:10:30 +0100
Message-ID: <20140304101030.GA8532@netboy>
References: <CALCETrULL_QJqSLSCcySdUdj5sGgh8A7gyEn=vpgCC4LDjPHFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:58290 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661AbaCDKKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:10:36 -0500
Received: by mail-ee0-f42.google.com with SMTP id d17so4706412eek.29
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 02:10:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrULL_QJqSLSCcySdUdj5sGgh8A7gyEn=vpgCC4LDjPHFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2014 at 06:20:33PM -0800, Andy Lutomirski wrote:
> AFAICT is sets SOCK_TIMESTAMPING_RX_HARDWARE, which appears to do
> exactly nothing.  If I'm right, should I submit a patch documenting
> that fact and removing the getsockopt/setsockopt implementations?

Have you seen Documentation/networking/timestamping.txt?

  SOF_TIMESTAMPING_TX/RX determine how time stamps are generated.
  SOF_TIMESTAMPING_RAW/SYS determine how they are reported in the
  following control message:

This is the API that was invented (not by me) to support HW time stamp
reporting. I agree that it is confusing and complicated, but I don't
think you can remove the flag as it is a firmly established API.
Drivers do use this to advertise whether they support receive time
stamps in hardware.

AFAICT, the reason why setting this socket option is a noop is
this. Once receive time stamping is enabled at the driver level,
eligible skbs will get the information whether they want it or not.
It would be more work to hide this from sockets which haven't enabled
the option, and so we don't do it.

HTH,
Richard
