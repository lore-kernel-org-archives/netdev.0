From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Sat, 18 Dec 2010 01:08:33 -0800
Message-ID: <AANLkTimSH_NfX2qno7sO3A4CHLsONmRUDHzWXY4reD28@mail.gmail.com>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
	<20101217.211309.226761639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com, chavey@google.com,
	ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:24205 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab0LRJIf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 04:08:35 -0500
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oBI98YHa021033
	for <netdev@vger.kernel.org>; Sat, 18 Dec 2010 01:08:34 -0800
Received: from yxl31 (yxl31.prod.google.com [10.190.3.223])
	by wpaz9.hot.corp.google.com with ESMTP id oBI98XEO008226
	for <netdev@vger.kernel.org>; Sat, 18 Dec 2010 01:08:34 -0800
Received: by yxl31 with SMTP id 31so772470yxl.0
        for <netdev@vger.kernel.org>; Sat, 18 Dec 2010 01:08:33 -0800 (PST)
In-Reply-To: <20101217.211309.226761639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

resend in plain text.

On Fri, Dec 17, 2010 at 9:13 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Nandita Dukkipati <nanditad@google.com>
> Date: Fri, 17 Dec 2010 19:20:51 -0800
>
>> This patch changes the default initial receive window to 10 mss
>> (defined constant). The default window is limited to the maximum
>> of 10*1460 and 2*mss (when mss > 1460).
>>
>> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
>
> That's an incredibly terse explanation for a very non-trivial
> change with very non-trivial implications.
>
> What analysis have you performed to lead you to decide that this
> was a reasonable change to make? =A0Where can people see that
> analysis and look over it to see if they agree with your
> assesment of the data?

Apologies for the terse comment. Here's a longer explanation.

Background:
A recent proposal to the IETF [Ref: 5] recommends increasing TCP's
initial congestion window to 10 mss or about 15KB. This proposal,
backed with data from several large-scale live experiments as well as
controlled testbed experiments, is under active discussion in the TCPM
working group.

Analysis performed:
Leading up to this proposal were several large-scale Internet
experiments [Ref: 2] with an initial congestion window of 10 mss
(IW10), where we showed that the average latency of HTTP responses
improved by approximately 10%. This was accompanied by a slight
increase in retransmission rate (0.5%), most of which is coming from
applications opening multiple simultaneous connections. To understand
the extreme
worst case scenarios, as well as fairness issues with IW10 versus IW3
traffic, we further conducted controlled testbed experiments
(end-hosts are all Linux based). We came away finding minimal negative
impact even under low link bandwidths (dial-ups) and small buffers
[Ref: 3]. These results are extremely encouraging to adopting IW10.

But obviously, an initial congestion window of 10 mss is useless
unless a TCP receiver advertises an initial receive window of at least
10 mss. Fortunately, in the large-scale Internet experiments we found
that most of the operating systems advertised a large enough initial
receive window, allowing us to experiment with various values of
initial congestion windows. Linux systems were among the few
exceptions that advertised a small receive window. This patch intends
to fix that.

References:

1. This site has a comprehensive list of all IW10 references to date.
http://code.google.com/speed/protocols/tcpm-IW10.html

2. Paper describing results from large-scale Internet experiments with =
IW10.
http://ccr.sigcomm.org/drupal/?q=3Dnode/621

3. Controlled testbed experiments with IW10 under worst case scenarios
http://www.ietf.org/proceedings/79/slides/tcpm-0.pdf

4. Raw test data from testbed experiments (Linux senders/receivers)
with initial congestion window and initial receive window of 10 mss.
http://research.csc.ncsu.edu/netsrv/?q=3Dcontent/iw10

5. Internet-Draft. Increasing TCP's Initial Window.
https://datatracker.ietf.org/doc/draft-ietf-tcpm-initcwnd/
