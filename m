From: Eduardo Valentin <eduval@amazon.com>
Subject: Re: [PATCH 1/1] bridge: mdb: report complete_info ptr as not a
 kmemleak
Date: Wed, 5 Jul 2017 09:05:14 -0700
Message-ID: <20170705160514.GA11351@u40b0340c692b58f6553c.ant.amazon.com>
References: <1499101594-22421-1-git-send-email-eduval@amazon.com>
 <20170704.014842.1942928249505987408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <eduval@amazon.com>, <stephen@networkplumber.org>,
        <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170704.014842.1942928249505987408.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2017 at 01:48:42AM -0700, David Miller wrote:
> From: Eduardo Valentin <eduval@amazon.com>
> Date: Mon, 3 Jul 2017 10:06:34 -0700
> 
> > We currently get the following kmemleak report:
>  ...
> > This patch flags the complete_info ptr object as not a leak as it will
> > get freed when .complete_priv() is called,
> 
> We don't call .complete_priv().  We call .complete().

True, I can fix this wording in the commit next version.

> 
>  for the br mdb case, it
> > will be freed at br_mdb_complete().
> > 
> > Cc: stable <stable@vger.kernel.org> # v4.9+
> > Reviewed-by: Vallish Vaidyeshwara <vallish@amazon.com>
> > Signed-off-by: Eduardo Valentin <eduval@amazon.com>
> 
> I don't understand why kmemleak cannot see this.
> 
> We store the pointer globally when we do the switchdev_port_obv_add()
> call and it should be able to see that.

I see and agree. But even then I get these reports consistently on RTM_NEWMDB type.
This is why I am proposing marking as a non-kmemleak.

To me, this is only a leak if .complete() never gets called.


-- 
All the best,
Eduardo Valentin
