From: Neal Cardwell <ncardwell@google.com>
Subject: Re: tcp_bbr: Forcing set of BBR congestion control as default
Date: Mon, 2 Jan 2017 13:17:09 -0500
Message-ID: <CADVnQy=q88Hvh2aYnGCpCQH_b5PNwTZr_AWfgU0NnuSs6aatVQ@mail.gmail.com>
References: <CA+icZUXd8fN5BAZuCna=zpgSJcXivSG1S6cV1eMMJMWwL7RrLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35183 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933545AbdABSRk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 13:17:40 -0500
Received: by mail-oi0-f44.google.com with SMTP id b126so487332897oia.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 10:17:40 -0800 (PST)
In-Reply-To: <CA+icZUXd8fN5BAZuCna=zpgSJcXivSG1S6cV1eMMJMWwL7RrLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 12:05 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>
> Hi,
>
> I am trying to force the set of BBR congestion control as default.
> My old linux-config uses CUBIC as default.
> I want both BBR and CUBIC to be built but BBR shall be my default.
>
> I tried the below snippet.
>
> I refresh my new linux-config like this...
>
> $ MAKE="make V=1" ; COMPILER="mycompiler" ; MAKE_OPTS="CC=$COMPILER
> HOSTCC=$COMPILER" ; yes "" | $MAKE $MAKE_OPTS oldconfig && $MAKE
> $MAKE_OPTS silentoldconfig < /dev/null
>
> What am I doing wrong?

Perhaps your build directory already has an old .config file that sets
the DEFAULT_TCP_CONG to be "cubic", and your "make oldconfig" and
"make silentoldconfig" are maintaining those lines from the old
.config?

If you want to start with your existing .config but then make BBR the
default, then it might be simplest just to edit your .config directly:

-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="bbr"

BTW, I presume you have seen the warning in the BBR commit message or
tcp_bbr.c about ensuring that BBR is used with the "fq" qdisc:

  NOTE: BBR *must* be used with the fq qdisc ("man tc-fq") with pacing
  enabled, since pacing is integral to the BBR design and
  implementation. BBR without pacing would not function properly, and
  may incur unnecessary high packet loss rates.

The BBR quick-start guide has some details about how to build and
enable BBR and fq:

  https://github.com/google/bbr/blob/master/Documentation/bbr-quick-start.md

Hope that helps,
neal
