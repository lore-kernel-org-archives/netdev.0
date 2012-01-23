From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC Hanging clean-up of a namespace
Date: Sun, 22 Jan 2012 22:25:52 -0800
Message-ID: <m1aa5frl3j.fsf@fess.ebiederm.org>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
	<201201201251.25032.hans.schillstrom@ericsson.com>
	<m1r4yurt4w.fsf@fess.ebiederm.org>
	<201201230707.33761.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	"equinox\@diac24.net" <equinox@diac24.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57748 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab2AWGXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 01:23:23 -0500
In-Reply-To: <201201230707.33761.hans.schillstrom@ericsson.com> (Hans
	Schillstrom's message of "Mon, 23 Jan 2012 07:07:32 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans Schillstrom <hans.schillstrom@ericsson.com> writes:

> On Friday 20 January 2012 21:55:27 Eric W. Biederman wrote:
>> My current hypothesis is that the namespace actually didn't get freed
>> until the tcp socket finished closing.  You can check by looking at when
>> __put_net and then cleanup_net are called.
>
> __put_net() is called just after tcp_write_timer() fires and then
> cleanup_net()

Hypothesis confirmed.  Your speed problem is that it is taking 2 minutes
in the pathological case for your tcp socket to close.

Do you have any clue why it is taking your sockets so long to close?
Is the other side simply not responding?

Eric
