From: Zack Weinberg <zackw@panix.com>
Subject: Re: "ip netns create" hangs forever, spamming console with
 "unregister_netdevice: waiting for lo to become free"
Date: Tue, 26 May 2015 14:56:41 -0400
Message-ID: <CAKCAbMj9tKg95mNyUQZxRHxtTTCb2BQxYLehtA8XjD7Sf_t1Cw@mail.gmail.com>
References: <CAKCAbMgkpFMX7cQS=c3eD802aKTWesCv1TW7n8mtBvqLF0BN8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbackend.panix.com ([166.84.1.89]:40628 "EHLO
	mailbackend.panix.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbEZS4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 14:56:43 -0400
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by mailbackend.panix.com (Postfix) with ESMTPSA id 5FAE6155D2
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 14:56:42 -0400 (EDT)
Received: by wizk4 with SMTP id k4so87497242wiz.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 11:56:41 -0700 (PDT)
In-Reply-To: <CAKCAbMgkpFMX7cQS=c3eD802aKTWesCv1TW7n8mtBvqLF0BN8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 12:21 PM, Zack Weinberg <zackw@panix.com> wrote:
> I have an application that makes heavy use of network namespaces,
> creating and destroying them on the fly during operation.  With 100%
> reproducibility, the first invocation of "ip netns create" after any
> "ip netns del" hangs forever in D-state; only rebooting the machine
> clears the condition.

Following up to myself to say that reproduction is not as simple as
'ip netns add test; ip netns del test; ip netns add test2'.  In fact,
not even bringing the namespace (and all associated interfaces) up and
then  down again _exactly_ as my production code does it will trigger
the bug.  It appears to be necessary to push a significant amount of
data through interfaces attached to the namespace.

Since I had to reset the machine to attempt to create a repro recipe,
I can no longer perform diagnostics on the hung processes, but I've
restarted the application and it should reach the problem state again
in a day or two.

zw
