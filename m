From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/2] cls_bpf: introduce integrated actions
Date: Fri, 18 Sep 2015 08:04:04 -0400
Message-ID: <55FBFDB4.30908@mojatatu.com>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
 <1442383543-4720-2-git-send-email-ast@plumgrid.com>
 <55FAB40E.304@mojatatu.com> <55FABC7B.6060502@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35971 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbbIRMEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 08:04:13 -0400
Received: by igcrk20 with SMTP id rk20so16237819igc.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 05:04:12 -0700 (PDT)
In-Reply-To: <55FABC7B.6060502@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On 09/17/15 09:13, Daniel Borkmann wrote:

> Hmm, I don't really agree. With cls_bpf you have non-linear
> classifications as opposed to walking a chain of classifiers:

A chain of classifiers is a better description today (non-linear would
be an appropriate description before cls_bpf ;->).

> worst case, I have to walk through N classifiers just to find
> out that the last one matches that I need to drop - this doesn't
> scale at all.

The scaling reason with that posted example is not
a strong one. You can get good performance with any classifier
for that policy description.
F.E with Alexei's second best classifier:->:

tc filter add dev eth0 parent ffff: protocol arp prio 1 u32\
match all ..
tc filter add dev eth0 parent ffff: protocol ip prio 1 u32\
...

But I do get the gist of your arguement otherwise and some
short circuits are ok as you had earlier.


>Given that we can make this decision right here,
> we can use this fact and have simple return codes provided as
> well.

I think it makes sense for the simple case.
But you have every other opcode in there, not just basic
accept/drop. I am worried this is leading towards an
enclave of bpf do-everything.


cheers,
jamal
