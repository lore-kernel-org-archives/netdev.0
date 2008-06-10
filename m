From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
	available to userspace
Date: Tue, 10 Jun 2008 12:49:08 +0100
Message-ID: <20080610114908.GA25798@gerrit.erg.abdn.ac.uk>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806011948.39770.tomasz@grobelny.oswiecenia.net> <20080604150942.GA4980@gerrit.erg.abdn.ac.uk> <200806081421.25688.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34271 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752490AbYFJLte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 07:49:34 -0400
Content-Disposition: inline
In-Reply-To: <200806081421.25688.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > But since it is about dynamic runtime configuration, how about using sysfs
| > or configfs instead? This is a brainstorming question, I think that sysfs
| > is generally preferred. I don't know how well configfs has taken off, it is
| > similar, but needs to be added in the configuration (under Pseudeo
| > Filesystems, CONFIG_CONFIGFS_FS=y|m) http://lwn.net/Articles/148973/
| > and Documentation/filesystems/configs. But this could be done later as
| > well.
| >
| procfs has some fine example of being used for this kind of information, 
| namely /proc/cpuinfo and /proc/meminfo

| sysfs: from sysfs-rules.txt: "(...) the sysfs interface cannot provide a 
| stable interface (...)"
Yes that is a key point and I think we are talking about the same point here.

I had mentioned sysfs/procfs as alternatives not because they are the best
possible match, but since it shows that similar problems (and likely solutions)
exist also in other areas.

But there are also areas where the rate of change is relatively low or
even absent: Documentation/ABI/README for instance mentions 4 different
levels of stability (stable/testing/obsolete/removed), the most entries
are under `testing'.

| configfs is for configuring kernel from userspace. Which is quite opposite to  
| what we want.
| 
Ok I think I understand now where you are heading - but then we can go a much
simpler route: why not implement a sysctl (which is also mirrored in /proc/sys)
that contains all available/implemented qpolicies as a space-separated
string, such as

	cat /proc/sys/net/ipv4/tcp_available_congestion_control ?

And I think that it is unnecessarily complex to add the available parameters
belonging to each qpolicy as well.

If we agree on using unique strings to identify qpolicies then we can
keep the runtime discovery much simpler. I think a manpage would be more
helpful here, since the runtime discovery of parameters is not
immediately obvious.

- Gerrit
