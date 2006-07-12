From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Unnecessary check in __sk_stream_mem_reclaim?
Date: Wed, 12 Jul 2006 14:42:36 +1200
Message-ID: <5640c7e00607111942jc0ef6cdyc0466dc0cfd5a00b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:36686 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S932353AbWGLCmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 22:42:37 -0400
Received: by nf-out-f131.google.com with SMTP id k65so5432nfa
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 19:42:36 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

It looks to me like this check here in net/core/stream.c for
__sk_stream_mem_reclaim:
	if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM) {

is unnecessary.

It is also done in include/net/sock.h for sk_stream_mem_reclaim which
if the test succeeds calls __sk_stream_mem_reclaim. This is the only
use of it in the kernel.

Now sk_stream_mem_reclaim seems to be in the current form for
perfomance reasons which make sense so I think it makes sense to
remove it from __sk_stream_mem_reclaim

The danger of removing the check is an external module could use it -
which I suspect is highly unlikely. This could be overcome by removing
the export_symbol_gpl and shifting the function into the header file
although this would result in mutliple instances being linked in. I am
guessing that there is a smarter way to do this though which still
results in the symbol not being exported. I don't know my way around
the linking/exporting very well.

Comments? I guess if this was done it would have to be put in feature
removal schedule though because it is currently exported?

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
