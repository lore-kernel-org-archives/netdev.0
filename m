From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [Patch] infiniband: check local reserved ports
Date: Thu, 03 Jun 2010 09:39:16 -0700
Message-ID: <ada1vcoqde3.fsf@roland-alpha.cisco.com>
References: <20100603083106.6047.7657.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	davem@davemloft.net, linux-rdma@vger.kernel.org,
	sean.hefty@intel.com
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100603083106.6047.7657.sendpatchset@localhost.localdomain>
	(Amerigo Wang's message of "Thu, 3 Jun 2010 04:27:02 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Since Tetsuo's patch already got merged, now this is the missing part
 > for local port reservation.
 > 
 > Cc: Roland Dreier <rdreier@cisco.com>
 > Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
 > Signed-off-by: WANG Cong <amwang@redhat.com>
 > 
 > ---
 > diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
 > index b930b81..7b89bab 100644
 > --- a/drivers/infiniband/core/cma.c
 > +++ b/drivers/infiniband/core/cma.c
 > @@ -1978,6 +1978,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 >  	rover = net_random() % remaining + low;
 >  retry:
 >  	if (last_used_port != rover &&
 > +	    !inet_is_reserved_local_port(rover) &&
 >  	    !idr_find(ps, (unsigned short) rover)) {
 >  		int ret = cma_alloc_port(ps, id_priv, rover);
 >  		/*

Should this inet_is_reserved_local_port() test apply to all the "port
spaces" that this code is handling?  I honestly am ignorant of the
intended semantics of the new local_reserved_ports stuff, hence my question.

 - R.
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
