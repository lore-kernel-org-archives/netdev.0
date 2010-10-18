From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] vmxnet3: remove set_flag_le{16,64} functions
Date: Mon, 18 Oct 2010 11:44:55 -0700
Message-ID: <AANLkTikC3KorhkWBkRPE_UQ8H_M=gWm3QnpPvYOVeTxM@mail.gmail.com>
References: <1287214392-8963-1-git-send-email-harvey.harrison@gmail.com>
	<89E2752CFA8EC044846EB8499819134102BD7E1856@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:64975 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab0JRSo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 14:44:56 -0400
Received: by pwj4 with SMTP id 4so253451pwj.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 11:44:55 -0700 (PDT)
In-Reply-To: <89E2752CFA8EC044846EB8499819134102BD7E1856@EXCH-MBX-4.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 16, 2010 at 8:57 AM, Shreyas Bhatewara
<sbhatewara@vmware.com> wrote:
> This hunk is wrong, UPT1_F_RXVLAN should be reset here.
>
> I fail to understand why set/reset functions were not good enough and why this opencoding is required. I agree with your earlier suggestion about replacing two conversions with *data |= cpu_to_le16(flag); though.
>
>

There's nothing really _wrong_ with them, they are a bit special-case,
and they are incomplete in that there is only 16/64 and
no 32 bit version.  And the naming is usually set/clear rather than set/reset.

That, and they are used so infrequently, why not just define the
constants as little endian and then it's just
use regular bitwise math which is common everywhere in networking?
Then others reading your driver don't have
to go look at a special-case set/reset function...it's just or'ing a flag.

I'll send a patch this evening so you can see what it would look like.

Harvey
