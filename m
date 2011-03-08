From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: [rds-devel] [PATCH] rds: prevent BUG_ON triggering on congestion
 map updates
Date: Tue, 8 Mar 2011 15:36:37 -0800 (PST)
Message-ID: <1b2c4f6b-57db-430c-9bf4-7fd63b8c513e@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <rds-devel@oss.oracle.com>,
	<chris.mason@oracle.com>, <davem@davemloft.net>
To: <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:39365 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755842Ab1CHXiH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 18:38:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was trying to recreate on our test systems. It's not a ppc.
So far not successful in crashing even though rds_ib_xmit hits this path: 
        /* Do not send cong updates to IB loopback */
        if (conn->c_loopback
            && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
                rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
                return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
        }

For the BUG_ON condition in rds_send_xmit:
ret=4096  conn->c_xmit_sg=1 rm->data.op_nents=2
BUG_ON(ret != 0 && conn->c_xmit_sg == rm->data.op.nents);

Venkat

----- Original Message -----
From: nhorman@tuxdriver.com
To: davem@davemloft.net
Cc: chris.mason@oracle.com, netdev@vger.kernel.org, rds-devel@oss.oracle.com, venkat.x.venkatsubra@oracle.com
Sent: Tuesday, March 8, 2011 1:36:50 PM GMT -06:00 US/Canada Central
Subject: Re: [rds-devel] [PATCH] rds: prevent BUG_ON triggering on congestion map updates

On Tue, Mar 08, 2011 at 11:22:58AM -0800, David Miller wrote:
> From: Chris Mason <chris.mason@oracle.com>
> Date: Tue, 08 Mar 2011 13:58:57 -0500
> 
> > Excerpts from David Miller's message of 2011-03-08 13:52:23 -0500:
> >> From: Chris Mason <chris.mason@oracle.com>
> >> Date: Mon, 07 Mar 2011 15:41:04 -0500
> >> 
> >> > Excerpts from David Miller's message of 2011-03-07 15:27:53 -0500:
> >> >> From: Neil Horman <nhorman@tuxdriver.com>
> >> >> Date: Wed,  2 Mar 2011 11:28:22 -0500
> >> >> 
> >> >> > Recently had this bug halt reported to me:
> >> >> 
> >> >> Well, does anyone on the RDS team care about this bug fix at all?
> >> >> 
> >> >> Stuff like this should not sit for nearly a week without any reply
> >> >> whatsoever.
> >> >> 
> >> > 
> >> > The patch looks good to me, but I'm surprised we haven't seen it here.
> >> > Venkat please take a look (link to the patch below)  Has it only been seen on ppc?
> >> > 
> >> > http://permalink.gmane.org/gmane.linux.network/187933
> >> 
> >> Can I get an ACK or something, _please_?
> > 
> > Sorry, wasn't clear:
> > 
> > Acked-by: Chris Mason <chris.mason@oracle.com>
> 
> Applied, thanks everyone.
Thanks, Chris, Dave.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
