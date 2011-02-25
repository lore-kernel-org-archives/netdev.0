From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 15:33:26 -0800
Message-ID: <AANLkTinJZMCf6vvrZunwSb1uNhwKFAgE_sb1TUPr=W9u@mail.gmail.com>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
	<AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
	<20110225125644.GA9763@canuck.infradead.org>
	<AANLkTinNost8Swh2fhQh8UXVdPTW_bToS7LXmyuwqNNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:47813 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933045Ab1BYXda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 18:33:30 -0500
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p1PNXSo7002378
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 15:33:29 -0800
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by kpbe11.cbf.corp.google.com with ESMTP id p1PNXQTe011759
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 15:33:27 -0800
Received: by qwj9 with SMTP id 9so1919551qwj.8
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 15:33:26 -0800 (PST)
In-Reply-To: <AANLkTinNost8Swh2fhQh8UXVdPTW_bToS7LXmyuwqNNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 11:51, Tom Herbert <therbert@google.com> wrote:
>> Tom, Bill: do you have a timeline for merging this? Especially the
>> UDP bits?
> Bill has been working on the TCP implementation which is requiring
> some fairly major surgery on the listener connections in syn-rcvd
> state, this is ongoing.

Yup.  The broad approach I settled on is to delay binding of new
connections to listener sockets by moving receive_sock's from a
per-listen_sock hash table to new hash chains in the global hash
table.

This is very much a work-in-progress.  I'm part way through the
conversion and have running code with most of the new structures in
place in parallel with the old; I'm about to start relying exclusively
on the new, and then will tear down the old; once that's done I'll be
in a position to hook that up to SO_REUSEPORT and start actually
measuring the difference.  In short: it will be a while.

So splitting SO_REUSEPORT for UDP from SO_REUSEPORT for TCP makes a
lot of sense to me.
