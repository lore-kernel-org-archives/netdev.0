From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Thu, 28 Jan 2016 13:51:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCCEDE4@AcuExch.aculab.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"marek@cloudflare.com" <marek@cloudflare.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"pabeni@redhat.com" <pabeni@redhat.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:56058 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbcA1NyF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 08:54:05 -0500
In-Reply-To: <cover.1453913331.git.marcelo.leitner@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 27 January 2016 17:07
> This patchset is merely a RFC for the moment. There are some
> controversial points that I'd like to discuss before actually proposing
> the patches.

You also need to look at how a 'user' can actually get SCTP to
merge data chunks in the first place.

With Nagle disabled (and it probably has to be since the data flow
is unlikely to be 'command-response' or 'unidirectional bulk')
it is currently almost impossible to get more than one chunk
into an ethernet frame.

Support for MSG_MORE would help.

Given the current implementation you can get almost the required
behaviour by turning nagle off and on repeatedly.

I did wonder whether the queued data could actually be picked up
be a Heartbeat chunk that is probing a different remote address
(which would be bad news).

	David
