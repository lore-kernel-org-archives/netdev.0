From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 5/5] tcp: ipv4 listen state scaled
Date: Wed, 27 Oct 2010 19:04:34 +0400
Message-ID: <20101027150434.GA13121@ms2.inr.ac.ru>
References: <AANLkTikRsOevLBHn0xb0S_YvfPMWpAdw373bxQUc+xbV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Dmitry Popov <dp@highloadlab.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:60189 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756268Ab0J0PEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 11:04:46 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikRsOevLBHn0xb0S_YvfPMWpAdw373bxQUc+xbV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

It looks like there is at least one hole here.

You take lock, check syn table and drop lock in tcp_v4_hnd_req().
Then you immediately enter tcp_v4_conn_request() and grab lock again.
Oops, in the tiny hole while lock was dropped the request can be already
created (even funnier, the whole socket can be already created and even accepted).
So, if you drop lock, you have to restart the whole tcp_v4_rcv_listen()
(which seems to be impossible without additional tricks)

Alexey
