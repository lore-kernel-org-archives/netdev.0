From: Dave Jones <davej@redhat.com>
Subject: Re: net_dma: mark broken
Date: Mon, 23 Dec 2013 11:21:13 -0500
Message-ID: <20131223162113.GA20363@redhat.com>
References: <20131220211228.BC817660C74@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757794Ab3LWQVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 11:21:21 -0500
Content-Disposition: inline
In-Reply-To: <20131220211228.BC817660C74@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 09:12:28PM +0000, Linux Kernel wrote:
 > Gitweb:     http://git.kernel.org/linus/;a=commit;h=77873803363c9e831fc1d1e6895c084279090c22
 > Commit:     77873803363c9e831fc1d1e6895c084279090c22
 > Parent:     0baf8f6a2ac86c2c40ed0cacab8ea3d17371a1bb
 > Author:     Dan Williams <dan.j.williams@intel.com>
 > AuthorDate: Tue Dec 17 10:09:32 2013 -0800
 > Committer:  Dan Williams <dan.j.williams@intel.com>
 > CommitDate: Wed Dec 18 12:53:43 2013 -0800
 > 
 >     net_dma: mark broken
 >     
 >     net_dma can cause data to be copied to a stale mapping if a
 >     copy-on-write fault occurs during dma.  The application sees missing
 >     data.


Since this commit, coverity picked up a possible logic contradiction in tcp_rcv_established
Now that the only thing setting copied_early = 1 is inside an ifdef that won't be set,
it notes that this code is unreachable..

5271                        if (!copied_early || tp->rcv_nxt != tp->rcv_wup)
5272                                __tcp_ack_snd_check(sk, 0);

I don't understand all the subtleties of that huge function, so another
set of eyes would be appreciated.  If it's a non-issue, I'll flag it as such
for coverity so it doesn't get picked up again.

	Dave
