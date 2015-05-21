From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 09/10] pktgen: add sample script
 pktgen_sample03_burst_single_flow.sh
Date: Thu, 21 May 2015 11:47:35 +0200
Message-ID: <20150521114735.4e2ea1a1@redhat.com>
References: <20150519213326.9070.18264.stgit@ivy>
	<20150519213639.9070.50273.stgit@ivy>
	<CAHA+R7NVB8EaiSMQeEw9atPy_7hz0YrBSazMK9zwDEJC5CpB2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>, brouer@redhat.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760AbbEUJrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 05:47:42 -0400
In-Reply-To: <CAHA+R7NVB8EaiSMQeEw9atPy_7hz0YrBSazMK9zwDEJC5CpB2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 May 2015 14:33:42 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Tue, May 19, 2015 at 2:36 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > +# Threads are specified with parameter -t value in $THREADS
> > +for ((thread = 0; thread < $THREADS; thread++)); do
> > +    dev=${DEV}@${thread}
> > +
> > +    # Add remove all other devices and add_device $dev to thread
> > +    pg_thread $thread "rem_device_all"
> > +    pg_thread $thread "add_device" $dev
> > +
> > +    # Base config
> > +    pg_set $dev "flag QUEUE_MAP_CPU"
> > +    pg_set $dev "count $COUNT"
> > +    pg_set $dev "clone_skb $CLONE_SKB"
> > +    pg_set $dev "pkt_size $PKT_SIZE"
> > +    pg_set $dev "delay $DELAY"
> > +    pg_set $dev "flag NO_TIMESTAMP"
> > +
> > +    # Destination
> > +    pg_set $dev "dst_mac $DST_MAC"
> > +    pg_set $dev "dst $DEST_IP"
> > +
> > +    # Setup burst, for easy testing -b 0 disable bursting
> > +    # (internally in pktgen default and minimum burst=1)
> > +    if [[ ${BURST} != 0 ]]; then
> 
> 
> Nit: probably you mean: [[ ${BURST} -ne 0 ]]

With bash this still works (comparing it as a string), but I guess it
is more correct as you propose to compare it as a number.

You do realize that this cause $BURST to be evaluated as an arithmetic
expression, thus input like "10-10" will also disable bursting.

In bash it's also possible to write as: (( $BURST != 0 )) to be more
explicit that this is an arithmetic expression, and then we don't use
the -eq, -ne etc.

I'm fine with taking your proposal, as it also works with single "["
(although it does not fall for the arithmetic expansion).


> > +       pg_set $dev "burst $BURST"
> > +    else
> > +       info "$dev: Not using burst"
> > +    fi
> > +done



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
