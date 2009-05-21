From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: ipt_MASQUERADE weirdness (consuming CPU cycles while not used)
Date: Thu, 21 May 2009 23:10:29 +0300
Message-ID: <200905212310.29661.denys@visp.net.lb>
References: <200905182219.30216.denys@visp.net.lb> <4A1596D4.6000708@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A1596D4.6000708@netfilter.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 May 2009 21:00:52 Pablo Neira Ayuso wrote:
> Denys Fedoryschenko wrote:
> > I have loaded pppoe (1700 users). I test one rule for short time with -j
> > MASQUERADE, then removed it and reset conntrack (conntrack -F). But still
> > i can see it is consuming CPU even when it is not used in any rule. Even
> > i reboot server and just load rules that dont have MASQUERADE, and just
> > load module - it will start consuming CPU immediately.
>
> Are you using 2.6.29 with any conntrack helper loaded? In that case this
> fix is not in -stable yet.
>
> http://kerneltrap.org/mailarchive/linux-netdev/2009/4/8/5440564
>
> > 64811     3.7735  ipt_MASQUERADE           ipt_MASQUERADE          
> > device_cmp
>
> device_cmp() by nf_ct_iterate_cleanup() when NETDEV_DOWN event is
> received. Weird, is your device going down quite often? Another
> possibility is that there's some entry stuck in the conntrack table that
> we cannot delete, perhaps we're leaking refcounts somewhere.
It is loaded pppoe server (2k interfaces), sure they are 
appearing-disappearing non-stop. Thats maybe case, but weird that it is 
consuming CPU time while module not used at all anywhere (no rules with 
MASQUERADE).

