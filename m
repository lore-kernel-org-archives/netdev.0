From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net-timestamp: Fix a documentation typo
Date: Tue, 25 Nov 2014 09:33:42 +0100
Message-ID: <20141125083342.GA4411@localhost.localdomain>
References: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
 <CA+FuTSenSVXP-=hH+erpoE7yz1HbF8n9PeD_Xof-W=3GaQ6OFA@mail.gmail.com>
 <CALCETrU6tjwZoSCdfXnnhRy5H0uG9B8h5ftu9tA42iBuLXTQog@mail.gmail.com>
 <CA+FuTSe8pjpUUpStfEHsuZ2Row9=MHVPH0S-MjUxiauBSNMOsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34719 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaKYIds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 03:33:48 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so565672wiw.9
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 00:33:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CA+FuTSe8pjpUUpStfEHsuZ2Row9=MHVPH0S-MjUxiauBSNMOsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 05:38:21PM -0500, Willem de Bruijn wrote:
> The datagram feature existed before I added the counter and stream
> support, so returning the entire packet in that case is legacy
> behavior, I suppose. I did not intend to expose network headers for
> the new stream socket interface, though.

I suppose that idea (not mine) behind returning the entire frame was
to allow the user to send multiple frames, and then figure out which
time stamp goes with which sent frame. The whole thing is weak for two
reasons, firstly you aren't able to send two identical frames, and
secondly there are quite a few time stamping cards out there which
only handle one transmit time stamp at a time. Thus the ptp4l
application always waits for the hardware time stamp before sending
another frame and never looks at the returned frame data.

Thanks,
Richard
