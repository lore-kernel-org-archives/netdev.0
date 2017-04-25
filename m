From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/4] netlink: make extended ACK setting NULL-friendly
Date: Tue, 25 Apr 2017 10:13:34 +0200
Message-ID: <1493108014.2592.1.camel@sipsolutions.net>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
         <20170425080644.122536-2-jakub.kicinski@netronome.com>
         (sfid-20170425_100815_174836_54D64311)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52292 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1176119AbdDYINi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 04:13:38 -0400
In-Reply-To: <20170425080644.122536-2-jakub.kicinski@netronome.com> (sfid-20170425_100815_174836_54D64311)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-25 at 01:06 -0700, Jakub Kicinski wrote:

> +#define NL_SET_ERR_MSG(extack, msg) do {		\
> +	struct netlink_ext_ack *_extack = (extack);	\
> +	static const char _msg[] = (msg);		\
> +							\
> +	if (_extack)					\
> +		_extack->_msg = _msg;			\
> +	else						\
> +		pr_info("%s\n", _msg);			\
>  } while (0)

That's a good point, I used it only for genetlink so far where it was
guaranteed non-NULL.

I'm not really sure about the printing though - I'd rather not people
start relying on that and then we convert to have non-NULL and the
message disappears as a result ...

johannes
