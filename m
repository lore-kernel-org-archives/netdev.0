From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 5 Mar 2015 10:23:30 +0100
Message-ID: <20150305092330.GC25656@unicorn.suse.cz>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
 <54F77336.7040006@plumgrid.com>
 <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu>
 <54F7997A.3020604@plumgrid.com>
 <20150305065053.GA2062@nanopsycho.orion>
 <20150305072413.GB25656@unicorn.suse.cz>
 <96C60242-C380-4B97-9BA5-6E88ABFB18EC@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50926 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710AbbCEJXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 04:23:32 -0500
Content-Disposition: inline
In-Reply-To: <96C60242-C380-4B97-9BA5-6E88ABFB18EC@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2015 at 12:35:01AM -0800, Guy Harris wrote:
> 
> On Mar 4, 2015, at 11:24 PM, Michal Kubecek <mkubecek@suse.cz> wrote:
> 
> > To be more precise, it does not need it now as there is no syntax for
> > pcap filter on TPID,
> 
> In the current version of libpcap (and the commit dates back to November
> 2011), the filter "vlan" checks both for 0x8100 and 0x9100

Actually, there are four different pieces of code:

  - userspace checking packet contents
  - userspace checking packet metadata
  - kernel BPF checking packet contents
  - kernel BPF checking packet metadata

As far as I can see, only the BPF generated to check packet contents
does check TPID value, BPF checking metadata does not (neither in kernel
nor in userspace).

> (it should perhaps also check for other TPID values), in userland and
> in the kernel on platforms other than Linux, as the generated code
> checks for both values.
...
> (I presume that one can, from the data delivered to a PF_PACKET
> SOCK_RAW socket, reconstruct the packet as received, with all the VLAN
> tags in place in the packet just as they were when the packet hit the
> adapter's transceiver from the network.  If not, that's a *separate*
> deficiency.)

These two issues were addressed by

  https://github.com/the-tcpdump-group/libpcap/pull/351

but the code changed since then so I'll have to check the changes and
create a new pull request.

                                                       Michal Kubecek
