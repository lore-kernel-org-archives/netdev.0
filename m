From: "Tom Spink" <tspink@gmail.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Tue, 8 Jan 2008 23:39:58 +0000
Message-ID: <7b9198260801081539x7aee72fbm53b5f298c5faf56@mail.gmail.com>
References: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com>
	 <4783FBD6.1000004@hp.com>
	 <7b9198260801081453s198af7efycc7c35668c65eaf1@mail.gmail.com>
	 <alpine.BSF.1.00.0801081716010.24286@pkunk.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: "Brent Casavant" <bcasavan@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:65453 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbYAHXj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:39:58 -0500
Received: by py-out-1112.google.com with SMTP id u52so26555pyb.10
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2008 15:39:58 -0800 (PST)
In-Reply-To: <alpine.BSF.1.00.0801081716010.24286@pkunk.americas.sgi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2008, Brent Casavant <bcasavan@sgi.com> wrote:
> On Tue, 8 Jan 2008, Tom Spink wrote:
>
> > Where in the code is the message length being sent across the socket?
>
> In do_producer(), there are the following lines in the main loop:
>
>         /* Send random lengths of data */
>         messages[i].length = (rand() % MAXLEN) + sizeof(size_t);
>         iov[i].iov_len = messages[i].length;
>
> The entire "struct sockmsg" is sent across the socket, so the first
> size_t in each message contains the length of the entire message
> (including the size_t).  This size gets picked up at the
> recv(...,MSG_PEEK) line in do_consumer().
>
> Thanks,
> Brent
>
> --
> Brent Casavant                          All music is folk music.  I ain't
> bcasavan@sgi.com                        never heard a horse sing a song.
> Silicon Graphics, Inc.                    -- Louis Armstrong
>

Hi,

But you're not consuming the size_t on the other end.  You're only
peeking it, i.e. you're doing the recv to peek at the message, but
never calling recv to remove that data from the queue... or am I
missing something?

-- 
Regards,
Tom Spink
University of Edinburgh
