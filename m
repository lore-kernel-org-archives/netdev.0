From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 iproute2 9/9] man pages: add man page for skbmod
 action
Date: Fri, 13 Jan 2017 11:01:08 +0100
Message-ID: <20170113110108.19f8bffd@griffin>
References: <1476183648-25850-10-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        mrv@mojatatu.com, cdillaba@mojatatu.com, lucasb@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49196 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751444AbdAMKBR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 05:01:17 -0500
In-Reply-To: <1476183648-25850-10-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Oct 2016 07:00:48 -0400, Jamal Hadi Salim wrote:
> From: Lucas Bates <lucasb@mojatatu.com>
> 
> Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  man/man8/Makefile | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man/man8/Makefile b/man/man8/Makefile
> index 4ad96ce..de6f249 100644
> --- a/man/man8/Makefile
> +++ b/man/man8/Makefile
> @@ -16,7 +16,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
>  	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
>  	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
>  	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
> -	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 \
> +	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 tc-skbmod.8 \
>  	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
>  
>  all: $(TARGETS)

Seems that nobody really installs iproute2 :-)

The patch is missing the actual tc-skbmod.8 file which causes 'make
install' to fail:

install -m 0755 -d /tmp/ip/usr/share/man/man8
install -m 0644 ip-address.8 ip-link.8 ip-route.8 ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.8 tc.8 tc-bfifo.8 tc-bpf.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 tc-fq.8 tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 tc-pie.8 tc-mqprio.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 ip-addrlabel.8 ip-fou.8 ip-gue.8 ip-l2tp.8 ip-macsec.8 ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 ip-tcp_metrics.8 ip-netconf.8 ip-token.8 tipc.8 tipc-bearer.8 tipc-link.8 tipc-media.8 tipc-nametable.8 tipc-node.8 tipc-socket.8 tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 tc-tcindex.8 tc-u32.8 tc-matchall.8 tc-
 connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 tc-skbmod.8 tc-tunnel_key.8 devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8 /tmp/ip/usr/share/man/man8
install: cannot stat ‘tc-skbmod.8’: No such file or directory
make[2]: *** [install] Error 1
make[1]: *** [install] Error 2

Stephen, please revert commit a40995d1c79e5.

 Jiri
