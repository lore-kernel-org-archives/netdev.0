From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next 2/2] tools: test case for TPACKET_V3/TX_RING
 support
Date: Mon, 2 Jan 2017 18:02:42 -0500
Message-ID: <20170102230242.GC31716@oracle.com>
References: <cover.1483309545.git.sowmini.varadhan@oracle.com>
 <d26567a7226d392b8105f35be5cf25a17dbdf2ed.1483309545.git.sowmini.varadhan@oracle.com>
 <CAF=yD-JLDM9cekGTz7m3VYXmf4d+HEMX4dYZx=sB1X7+5drqsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17320 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751873AbdABXDA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 18:03:00 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-JLDM9cekGTz7m3VYXmf4d+HEMX4dYZx=sB1X7+5drqsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/02/17 17:31), Willem de Bruijn wrote:
> 
> Thanks for adding this.
> 
> walk_v3_tx is almost identical to walk_v1_v2_tx. That function can
> just be extended to add a v3 case where it already multiplexes between
> v1 and v2.

I looked at that, but the sticky point is that v1/v2 sets up the
ring->rd* related variables based on frames (e.g., rd_num is tp_frame_nr)
whereas V3 sets these up based on blocks (e.g, rd_num is  tp_block_nr) 
so this impacts the core sending loop a bit.

I suppose we could change the walk_v2_v2_tx to be something like
	while (total_packets > 0) {
		if (ring->version) {
		    /* V3 send, that takes above difference into account */
		} else {
		    /* existing code */
		}
		/* status_bar_update(), user_ready  update frame_num */
	}

I can change it as above, if you think this would help.

--Sowmini
