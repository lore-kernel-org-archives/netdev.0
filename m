From: Ben Greear <greearb@candelatech.com>
Subject: Re: Submission #3  for S2io 10GbE driver
Date: Tue, 02 Mar 2004 13:33:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4044FD93.8030006@candelatech.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDECB@orsmsx402.jf.intel.com> <4044FABE.9070408@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4044FABE.9070408@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> tg3 needs to kfree the skb too, leading to my comment "some existing 
> drivers get this wrong too".  Requeueing the skb only occurs in -some- 
> packet schedulers, not all.  So drivers cannot depend on the net stack 
> doing what you want in all cases.  Conditional correct behavior or 
> leak..  :/

I see lots of hard-start-xmit errors for e1000 and e100 in 2.4.25,
and it's very nice to be able to retry.  Lets fix the broken callers
instead of making the drivers less useful.

You can see this yourself with pktgen.  Here is the code in pktgen
where I see the printouts...if this is my bug, please let me know!

                         spin_lock_bh(&odev->xmit_lock);
                         if (!netif_queue_stopped(odev)) {
                                 if (odev->hard_start_xmit(next->skb, odev)) {
                                         if (net_ratelimit()) {
                                                 printk(KERN_INFO "Hard xmit error\n");
                                         }

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
