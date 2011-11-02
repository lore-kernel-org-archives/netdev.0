From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: TCP_CORK questions
Date: Wed, 2 Nov 2011 11:43:06 +0200
Message-ID: <CAOMsUML9ijO3WQetPLyo9nbfLNKUVuN5aanL_dCbJuKZUUwsmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: kernelnewbies@kernelnewbies.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47910 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab1KBJn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 05:43:28 -0400
Received: by iage36 with SMTP id e36so866810iag.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 02:43:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are using TCP_CORK with TCP_NODELAY. We are setting TCP_NODELAY
first and then setting TCP_CORK before sending a bunch of data
buffers. After sending all the buffers we are clearing TCP_CORK. The
expectation -- as per manpage -- is that when TCP_CORK is set small
data packets will not be sent. When TCP_CORK is removed it will
immediately send out the remaining data even if the remaining amount
is very small.

However, this is not the observed behavior. Small packets are sent at
an approximatively constant rate. Digging further into the manpage for
tcp we saw that there is a 200ms ceiling on the time for which the
output is corked. Can we change this limit somehow? Ideally, in our
case we would like to have userspace mark a socket such that it will
only send full packets as long as it is marked, even if the completion
comes after a long time.

Digging into tcp.c when the socket options are set, we found that if
when setting TCP_NAGLE_CORK we also disable TCP_NAGLE_PUSH the code
works as intended. Is this the right way to solve it? Code comments
suggest that disabling this flag there has no effect.

Thanks,
Mihai
