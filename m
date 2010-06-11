From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH] gianfar: Fix setup of RX time stamping
Date: Fri, 11 Jun 2010 16:20:23 +0400
Message-ID: <20100611122023.GA1598@oksana.dev.rtsoft.ru>
References: <95DC1AA8EC908B48939B72CF375AA5E3F03D8C46@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: 'David Miller' <davem@davemloft.net>,
	Richard Cochran <richard.cochran@omicron.at>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linuxppc-dev@ozlabs.org'" <linuxppc-dev@ozlabs.org>
To: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44891 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760114Ab0FKMUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:20:31 -0400
Received: by wyb40 with SMTP id 40so697602wyb.19
        for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 05:20:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E3F03D8C46@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 11, 2010 at 01:49:05PM +0200, Manfred Rudigier wrote:
> Previously the RCTRL_TS_ENABLE bit was set unconditionally. However, if
> the RCTRL_TS_ENABLE is set without TMR_CTRL[TE], the driver does not work
> properly on some boards (Anton had problems with the MPC8313ERDB and
> MPC8568EMDS).
> 
> With this patch the bit will only be set if requested from user space
> with the SIOCSHWTSTAMP ioctl command, meaning that time stamping is
> disabled during normal operation. Users who are not interested in time
> stamps will not experience problems with buggy CPU revisions or
> performance drops any more.
> 
> The setting of TMR_CTRL[TE] is still up to the user. This is considered
> safe because users wanting HW timestamps must initialize the eTSEC clock
> first anyway, e.g. with the recently submitted PTP clock driver.
> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
> ---

Looks OK. I tested that it doesn't break anything, but I didn't
test the timestamping functionality. So

Reviewed-by: Anton Vorontsov <cbouatmailru@gmail.com>

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
