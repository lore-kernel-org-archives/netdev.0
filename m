From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
	available to userspace
Date: Wed, 4 Jun 2008 16:09:42 +0100
Message-ID: <20080604150942.GA4980@gerrit.erg.abdn.ac.uk>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <20080526142209.GA20164@gerrit.erg.abdn.ac.uk> <200805262340.53355.tomasz@grobelny.oswiecenia.net> <200806011948.39770.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:45531 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752589AbYFDPKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 11:10:13 -0400
Content-Disposition: inline
In-Reply-To: <200806011948.39770.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Now that I had a closer look at implementing this functionality I have a few 
| questions:
| 1. Where should information about available qpolicies and their parametrs be 
| exported? Would /proc/net/dccp/qpolicies/ be a good choice?
For a sketch or a first implementation, procfs sounds like a good starting point.

But since it is about dynamic runtime configuration, how about using sysfs or configfs
instead? This is a brainstorming question, I think that sysfs is generally preferred.
I don't know how well configfs has taken off, it is similar, but needs to be
added in the configuration (under Pseudeo Filesystems, CONFIG_CONFIGFS_FS=y|m)
http://lwn.net/Articles/148973/
and Documentation/filesystems/configs. But this could be done later as well.


| 2. I guess we should have at least one file per qpolicy with parameters listed 
| inside. Like that:
| /proc/.../qpolicies/simple: <empty>
| /proc/.../qpolicies/prio: 1 (DCCP_SCM_PRIORITY) 2 (DCCP_SCM_TIMEOUT)
Hm this is a "policy" question -- isn't the `timeout' policy a
standalone variant?

| But we could also have qpolicy represented by directory and parameters by files:
| /proc/.../qpolicies/simple/
| /proc/.../qpolicies/prio/
| /proc/.../qpolicies/prio/priority: <empty>
| /proc/.../qpolicies/prio/timeout: <empty>
| Which layout do you find better?
| -- 
I don't like the empty files. In the procfs for thinkpad Acpi
configuration, for example, there is a line that says which commands are
acceptable, similar for /sys/power/state. In that way, the (sysfs|procfs) file
documents itself and tells the user what can be done with it. It would
be great if the qpolicies could do something similar.

I would start with the utterly simplest possible implementation and
leave complex cases for later. For a sophisticated, elegant
implementation, I would seriously consider sysfs or configs.
