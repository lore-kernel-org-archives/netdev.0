From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] pktgen: introduce xmit_mode 'rx_inject'
Date: Wed, 6 May 2015 07:24:40 +0200
Message-ID: <20150506072440.7afb2c44@redhat.com>
References: <20150505202730.8715.48527.stgit@ivy>
	<20150505202959.8715.51882.stgit@ivy>
	<55499996.2090308@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	brouer@redhat.com
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330AbbEFFYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 01:24:50 -0400
In-Reply-To: <55499996.2090308@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 May 2015 21:33:26 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> On 5/5/15 1:30 PM, Jesper Dangaard Brouer wrote:
> >
> > Introduce xmit_mode 'rx_inject' for pktgen which generates the packets
> > using familiar pktgen commands, but feeds them into
> > netif_receive_skb() instead of ndo_start_xmit().
> ...
> > pgset "xmit_mode rx_inject"
> 
> I think 'xmit_mode rx_inject' would make native english speaker cringe,
> since it's saying 'transmit mode is receive' ... but I don't mind :)

Yes, I know. Like Daniel suggested, I considered only calling it "rx"
but it made me cringe for this exact reason, thus I extended it with
"inject".  I'm flexible with the name of this...


> > Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ...
> > @@ -251,13 +255,14 @@ struct pktgen_dev {
> >   	 * we will do a random selection from within the range.
> >   	 */
> >   	__u32 flags;
> > -	int removal_mark;	/* non-zero => the device is marked for
> > -				 * removal by worker thread */
> > -
> > +	int xmit_mode;
> >   	int min_pkt_size;
> >   	int max_pkt_size;
> >   	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
> >   	int nfrags;
> > +	int removal_mark;	/* non-zero => the device is marked for
> > +				 * removal by worker thread */
> 
> I'm not sure why you're moving removal_mark field.

Because I wanted to place 'xmit_more' on a read-only/mostly cache-line,
although it likely does not matter too much, I just wanted to avoid any
funny cache coherency protocol interactions.


> Looks good. Thank you for doing this.
> Ack. My SOB is already there :)
> 
> btw, these patches didn't reach my subscribed to netdev email yet...
> something is stalling vger.

Hmm, that is strange. I think I see them. And they are on patchwork too.

https://patchwork.ozlabs.org/patch/468378/
https://patchwork.ozlabs.org/patch/468390/

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
