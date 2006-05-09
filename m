From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [RFC] SECMARK 1.0
Date: Tue, 09 May 2006 13:11:53 -0400
Message-ID: <1147194713.32651.108.camel@moss-spartans.epoch.ncsc.mil>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
	 <445E288B.4040908@gentoo.org> <Pine.LNX.4.64.0605071323330.9423@d.namei>
	 <1147110088.32719.56.camel@jackjack.columbia.tresys.com>
	 <Pine.LNX.4.64.0605081719440.18947@d.namei>
	 <1147181085.32719.105.camel@jackjack.columbia.tresys.com>
	 <Pine.LNX.4.64.0605091229190.25948@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Karl MacMillan <kmacmillan@tresys.com>,
	Joshua Brindle <method@gentoo.org>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:25571 "EHLO jazzhorn.ncsc.mil")
	by vger.kernel.org with ESMTP id S1750750AbWEIRI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 13:08:27 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605091229190.25948@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-05-09 at 12:40 -0400, James Morris wrote:
> On Tue, 9 May 2006, Karl MacMillan wrote:
> 
> > those connection, but my concern is that connection could, through error
> > or exploit, be passed to another domain that should not receive packets
> > from that type of connection (see below).
> 
> Connection passing or inheritence should be subject to kernel MAC controls 
> anyway (also see below).
> 
> > The use of a single related packet type loses the strong binding between
> > the connection type (determined on connection) and domains, most likely
> > because an established connection is passed to another process.
> > 
> > For example, for xinetd to work all of the xinetd children would be
> > allowed to receive all related packets (i.e., tracked_packet_t). This
> > means that if xinetd incorrectly passed, say, an ftp connection to
> > telnet it would still be allowed to receive those packets because they
> > would be of type tracked_packet_t. Labeling using something like
> > connmark seems to solve this problem.
> 
> My understanding of xinetd is that it execs server applications, which 
> inherit the connection fd.  In this case, flush_unauthorized_files() will 
> ensure that the new domain is authorized to access the fd.
> 
> Stephen, can you confirm this?

That doesn't help, as that is just a check based on the socket label,
which will always be based on xinetd's label and won't reflect anything
about the individual connection.

-- 
Stephen Smalley
National Security Agency

