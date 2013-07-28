From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 12:21:56 -0700
Message-ID: <1375039316.3669.36.camel@edumazet-glaptop>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130728185318.GA10795@neilslaptop.think-freely.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-07-28 at 14:53 -0400, Neil Horman wrote:
>  
> I agree, I think perhaps a loop higher up prior to the rrs_checked label to
> ensure that rfd_num is at least 1 prior to going through the rest of the rx
> path.  I'll have something for the reporters to test tomorrow.
> 

btw, this driver leaks skb horribly in this error path :

                if (rrs->word3 & (RRS_RX_ERR_SUM | RRS_802_3_LEN_ERR)) {
                        atl1c_clean_rfd(rfd_ring, rrs, rfd_num);
                                if (netif_msg_rx_err(adapter))
                                        dev_warn(&pdev->dev,
                                                "wrong packet! rrs word3 is %x\n",
                                                rrs->word3);
                        continue;
                }
