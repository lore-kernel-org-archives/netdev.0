From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why include/net/tcp_states.h is not exported to user-space?
Date: Wed, 1 Oct 2014 14:26:39 -0700
Message-ID: <CAHA+R7MG9AG0Poq3SdBro5+5VSaqWZVGsr1GRWVwA1-EFmFeqQ@mail.gmail.com>
References: <CAHA+R7MDGKA1Z-1ytk8-+9XaKNcW+kG7UBn8drhdbLJeQYBCyQ@mail.gmail.com>
	<20141001172500.GH2799@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:41655 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaJAV0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 17:26:41 -0400
Received: by mail-la0-f45.google.com with SMTP id q1so1219273lam.18
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 14:26:39 -0700 (PDT)
In-Reply-To: <20141001172500.GH2799@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 10:25 AM, Arnaldo Carvalho de Melo
<acme@kernel.org> wrote:
> Em Tue, Sep 30, 2014 at 11:12:04AM -0700, Cong Wang escreveu:
>> These states are needed for user-space to specify ->idiag_states.
>> Currently both libnl and ss make their own copy of these definitions.
>> Of course, new sock diag is not just limited to TCP, so we probably
>> need to rename them to SS_* before exporting them.
>>
>> I can send a patch if you agree.
>
> One would have to check what are the current best practices for doing
> that, i.e. probably this would have to go via
> include/uapi//linux/tcp_states.h? Or take the time and create a new
> header for the inet_diag.h stuff as this is not TCP specific for quite a
> while?

Exactly. The problem is, even in kernel, other protocols already use
these TCP_* states. Maybe we should really define SS_* first, and then
let each protocol define their own based on SS_*, including inet_diag?
