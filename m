From: Brent Casavant <bcasavan@sgi.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Tue, 8 Jan 2008 17:18:48 -0600 (CST)
Message-ID: <alpine.BSF.1.00.0801081716010.24286@pkunk.americas.sgi.com>
References: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com>  <4783FBD6.1000004@hp.com> <7b9198260801081453s198af7efycc7c35668c65eaf1@mail.gmail.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Tom Spink <tspink@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:56560 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752519AbYAHXSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:18:51 -0500
In-Reply-To: <7b9198260801081453s198af7efycc7c35668c65eaf1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jan 2008, Tom Spink wrote:

> Where in the code is the message length being sent across the socket?

In do_producer(), there are the following lines in the main loop:

	/* Send random lengths of data */
	messages[i].length = (rand() % MAXLEN) + sizeof(size_t);
	iov[i].iov_len = messages[i].length;

The entire "struct sockmsg" is sent across the socket, so the first
size_t in each message contains the length of the entire message
(including the size_t).  This size gets picked up at the
recv(...,MSG_PEEK) line in do_consumer().

Thanks,
Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
