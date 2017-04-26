From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/4] netlink: make extended ACK setting NULL-friendly
Date: Wed, 26 Apr 2017 09:17:48 +0200
Message-ID: <1493191068.2464.4.camel@sipsolutions.net>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
         <20170425080644.122536-2-jakub.kicinski@netronome.com>
         <1493108014.2592.1.camel@sipsolutions.net>
         <20170425135306.0ff1db27@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43594 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1952746AbdDZHR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 03:17:58 -0400
In-Reply-To: <20170425135306.0ff1db27@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-25 at 13:53 -0700, Jakub Kicinski wrote:
> On Tue, 25 Apr 2017 10:13:34 +0200, Johannes Berg wrote:
> > On Tue, 2017-04-25 at 01:06 -0700, Jakub Kicinski wrote:
> > 
> > > +#define NL_SET_ERR_MSG(extack, msg) do {		\
> > > +	struct netlink_ext_ack *_extack = (extack);	\
> > > +	static const char _msg[] = (msg);		\
> > > +							\
> > > +	if (_extack)					\
> > > +		_extack->_msg = _msg;			\
> > > +	else						\
> > > +		pr_info("%s\n", _msg);			\
> > >  } while (0)  

> I'm leaning towards dropping the else clause and never printing, that
> will add an incentive for people to convert more paths to provide the
> ext ack.  Any thoughts on that?

Personally, I'm happy with that.

johannes
