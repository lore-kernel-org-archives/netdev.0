From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v1 net-next 0/6] Extend socket timestamping API
Date: Thu, 27 Apr 2017 11:28:09 +0200
Message-ID: <20170427092809.GE5654@localhost>
References: <20170426145035.25846-1-mlichvar@redhat.com>
 <20170426165435.GA21114@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754607AbdD0J2O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 05:28:14 -0400
Content-Disposition: inline
In-Reply-To: <20170426165435.GA21114@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 06:54:35PM +0200, Richard Cochran wrote:
> On Wed, Apr 26, 2017 at 04:50:29PM +0200, Miroslav Lichvar wrote:
> > This patchset adds new options to the timestamping API that will be
> > useful for NTP implementations and possibly other applications.
> 
> Are there any userland ntp patches floating around to exercise the new
> HW time stamping option?

I'm not sure if anyone is working on support for HW timestamping in
ntp. With chrony, you can test it with an experimental code in the
hwts branch of https://github.com/mlichvar/chrony.

$ ./configure --enable-debug && make
# ./chronyd -d -d 'hwtimestamp *' 'server pool.ntp.org iburst' |& grep TIMESTAMP
 TX SCM_TIMESTAMPING: swts=1493285228.512531924 hwts=0.000000000
 TX SCM_TIMESTAMPING: swts=0.000000000 hwts=1493285226.073103885
 SCM_TIMESTAMPING_PKTINFO: if=2 len=90
 RX SCM_TIMESTAMPING: swts=1493285228.530657351 hwts=1493285226.091054104
 TX SCM_TIMESTAMPING: swts=1493285230.553457791 hwts=0.000000000
 TX SCM_TIMESTAMPING: swts=0.000000000 hwts=1493285228.113705104
 SCM_TIMESTAMPING_PKTINFO: if=2 len=90
 RX SCM_TIMESTAMPING: swts=1493285230.582817079 hwts=1493285228.142890229

-- 
Miroslav Lichvar
