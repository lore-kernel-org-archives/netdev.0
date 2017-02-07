From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 7 Feb 2017 10:54:22 -0800
Message-ID: <CACSApva7DeBcRUFG13Xb7YoegHcLWwwd=ecLVf9wSgNSKFbUDA@mail.gmail.com>
References: <20170207140144.GA11233@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:33426 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932166AbdBGTBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:01:20 -0500
Received: by mail-it0-f46.google.com with SMTP id d9so29119427itc.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 11:01:19 -0800 (PST)
In-Reply-To: <20170207140144.GA11233@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 6:01 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> 2) new SO_TIMESTAMPING option to receive from the error queue only
>    user data as was passed to sendmsg() instead of Ethernet frames
>
>    Parsing Ethernet and IP headers (especially IPv6 options) is not
>    fun and SOF_TIMESTAMPING_OPT_ID is not always practical, e.g. in
>    applications which process messages from the error queue
>    asynchronously and don't bind/connect their sockets.

This is going to be quite useful. However, I'm not sure if sending
back the original packet would be a proper API. Instead, one option is
to add a control message, so that applications can set the OPT_ID for
the timestamp. Perhaps, something like from user's perspective:

cmsg->cmsg_level             = SOL_SOCKET;
cmsg->cmsg_type              = SCM_TIMESTAMPING_OPT_ID;
cmsg->cmsg_len               = CMSG_LEN(sizeof(__u32));
*((__u32 *) CMSG_DATA(cmsg)) = my_id;

Thanks,
Soheil
