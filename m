From: Eric Dumazet <edumazet@google.com>
Subject: Re: network namespace bloat
Date: Tue, 10 Feb 2015 18:55:39 -0800
Message-ID: <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
	<87k2zubw7l.fsf@x220.int.ebiederm.org>
	<871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	roopa <roopa@cumulusnetworks.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	David Ahern <dsahern@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:43050 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbBKCzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 21:55:40 -0500
Received: by iecrp18 with SMTP id rp18so1030734iec.10
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 18:55:39 -0800 (PST)
In-Reply-To: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 6:42 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:

>
> Those large hash tables impact creation speed as large memory
> allocations require more work from the memory allocators, and they
> affect reliability of as order > 0 pages are not reliabily available in
> the kernel.  So from a network namespace perspective I would really like
> to convert the per network namespace hash tables to hash tables that
> have a single instance across all network namespaces.
>

tcp_metric can fallback to vzalloc() after commit 976a702ac9eea ?

There is nothing preventing to use a single tcp_metric, a bit like
global TCP hash table.

We only have to convert the thing...

Note : At Google we do not save tcp metrics.
We have to use it only for FastOpen cookies eventually (For clients)
