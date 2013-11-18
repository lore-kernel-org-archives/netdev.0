From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 65131] New: kernel panic (BUG_ON raised) in SCTP function
 sctp_cmd_interpreter
Date: Mon, 18 Nov 2013 09:14:28 -0800
Message-ID: <20131118091428.6360d82a@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:40040 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab3KRROb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 12:14:31 -0500
Received: by mail-pd0-f178.google.com with SMTP id p10so6723083pdj.23
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 09:14:31 -0800 (PST)
Received: from samsung-9 ([172.56.32.29])
        by mx.google.com with ESMTPSA id oj6sm28003427pab.9.2013.11.18.09.14.30
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Nov 2013 09:14:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 17 Nov 2013 19:38:56 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 65131] New: kernel panic (BUG_ON raised) in SCTP function sctp_cmd_interpreter


https://bugzilla.kernel.org/show_bug.cgi?id=65131

            Bug ID: 65131
           Summary: kernel panic (BUG_ON raised) in SCTP function
                    sctp_cmd_interpreter
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11.8 custom build, repeated on 3.11.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: yuras@uch.net
        Regression: No

Created attachment 114991
  --> https://bugzilla.kernel.org/attachment.cgi?id=114991&action=edit
Screenshot of panic

Two-node cluster configured using latest corosync (also DRBD 8.4.4, LVM2, and
GFS2 but this is unessential).
Steps to reproduce:
1. Start corosync on both nodes.
2. Start dlm_controld (version 4.0.2) on both nodes (used SCTP protocol as TCP
cannot be used on multi-homed hosts). Adds such lines to kern.log:
    kernel: [  580.428664] sctp: Hash tables configured (established 65536 bind
65536)
    kernel: [  580.441779] DLM installed
3. Start clvmd on either node. Adds such lines to kern.log:
    kernel: [ 1345.259502] dlm: Using SCTP for communications
    kernel: [ 1345.260699] dlm: clvmd: joining the lockspace group...
    kernel: [ 1345.262962] dlm: clvmd: dlm_recover 1
    kernel: [ 1345.262968] dlm: clvmd: group event done 0 0
    kernel: [ 1345.262992] dlm: clvmd: add member 1024
    kernel: [ 1345.262995] dlm: clvmd: dlm_recover_members 1 nodes
    kernel: [ 1345.262996] dlm: clvmd: join complete
    kernel: [ 1345.262998] dlm: clvmd: generation 1 slots 1 1:1024
    kernel: [ 1345.262999] dlm: clvmd: dlm_recover_directory
    kernel: [ 1345.263000] dlm: clvmd: dlm_recover_directory 0 in 0 new
    kernel: [ 1345.263002] dlm: clvmd: dlm_recover_directory 0 out 0 messages
    kernel: [ 1345.263019] dlm: clvmd: dlm_recover 1 generation 1 done: 0 ms
4. Start clvmd on second node. With high probability one node or both nodes
panic in the similar way. Screenshot in attachment.

Stack trace can differ slightly above EOI line, but RIP was always the same. I
suppose provided CPU codes correspond to one of BUG_ON macro inside
sctp_cmd_interpreter. So, this is a bug.

Now this bug totally prevents me from using my cluster as DLM rejects to use
TCP for multi-homed hosts.

-- 
You are receiving this mail because:
You are the assignee for the bug.
