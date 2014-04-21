From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v2] filter: added BPF random opcode
Date: Mon, 21 Apr 2014 14:54:12 -0700
Message-ID: <CA+ZOOTNnfUkqLT9wrmoHtP+-a5+7UzLvO0qeNjtknZX1K9kn3g@mail.gmail.com>
References: <1397585816-1267-1-git-send-email-chema@google.com>
	<1398097284-20528-1-git-send-email-chema@google.com>
	<CAMEtUuw=trzxSC9Dc+UAEU5HyHk1Ym3cW7L+7tmvOe2hzHmXMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:45999 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341AbaDUVyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 17:54:13 -0400
Received: by mail-ig0-f176.google.com with SMTP id uy17so2265979igb.15
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 14:54:12 -0700 (PDT)
In-Reply-To: <CAMEtUuw=trzxSC9Dc+UAEU5HyHk1Ym3cW7L+7tmvOe2hzHmXMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2014 at 2:46 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> as I was saying in the other thread, would be nice to see more
> realistic example, since "icmp 1 in 4" can be done in user space...
> What is the real problem being solved?
> I suspect for true packet sampling you'd need to have the knowledge
> of packet rate, potentially computing time delta within filter with
> another extension?
> The patch itself looks good to me.
Random sampling. There's a huge performance penalty if you do this in
user-space. You don't want to send all the packets to user-space to
just get (e.g.) 1 in 1000 and discard all the others.

>From http://www.icir.org/vern/papers/secondary-path-raid06.pdf:

When dealing with large volumes of network traffic, we can often
derive significant
benefit while minimizing the processing cost by employing sampling.
Generally, this
is done on either a per-packet or per-connection basis. BPF does not
provide access
to pseudo-random numbers, so applications have had to rely on proxies
for random-
ness in terms of network header fields with some semblance of entropy
across packets
(checksum and IP fragment identifier fields) or connections (ephemeral
ports). These
sometimes provide acceptable approximations to random sampling, but
can also suffer
from significant irregularities due to lack of entropy or aliasing;
see [11] for an analysis.

-Chema
