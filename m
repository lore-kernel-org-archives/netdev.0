From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v2] {net,IB}/{rxe,usnic}: Utilize generic mac to eui32
 function
Date: Tue, 7 Mar 2017 20:37:10 +0200
Message-ID: <20170307183709.GA9094@yuval-lap>
References: <1488826446-4173-1-git-send-email-yuval.shaia@oracle.com>
 <20170307142711.GS14379@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benve@cisco.com, dgoodell@cisco.com, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com, monis@mellanox.com,
        davem@davemloft.net, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:31188 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755292AbdCGTZK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 14:25:10 -0500
Content-Disposition: inline
In-Reply-To: <20170307142711.GS14379@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 07, 2017 at 04:27:11PM +0200, Leon Romanovsky wrote:
> On Mon, Mar 06, 2017 at 08:54:06PM +0200, Yuval Shaia wrote:
> > This logic seems to be duplicated in (at least) three separate files.
> > Move it to one place so code can be re-use.
> >
> > Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
> > ---
> > v0 -> v1:
> > 	* Add missing #include
> > 	* Rename to genaddrconf_ifid_eui48
> > v1 -> v2:
> > 	* Reset eui[0] to default if dev_id is used
> > ---
> >  drivers/infiniband/hw/usnic/usnic_common_util.h | 11 +++--------
> >  drivers/infiniband/sw/rxe/rxe_net.c             | 11 ++---------
> >  include/net/addrconf.h                          | 19 +++++++++++++------
> >  3 files changed, 18 insertions(+), 23 deletions(-)
> >
> >  	 * scope according to RFC2373.
> >  	 */
> >  	if (dev->dev_id) {
> > +		eui[0] = dev->dev_addr[0];
> >  		eui[3] = (dev->dev_id >> 8) & 0xFF;
> >  		eui[4] = dev->dev_id & 0xFF;
> > -	} else {
> > -		eui[3] = 0xFF;
> > -		eui[4] = 0xFE;
> > -		eui[0] ^= 2;
> >  	}
> > +
> >  	return 0;
> >  }
> 
> Technically, the code is correct now, but it doesn't look right
> to set the value and restore it right after that.

Agree.
I will soon send v3 that offers an alternative by adding new helper
function so this re-assignment can be avoid.

> 
> Thanks
> 
> >
> > --
> > 2.7.4
> >
