From: Ben Greear <greearb@candelatech.com>
Subject: Re: Patch to latest iproute to get it to compile on FC5
Date: Wed, 13 Feb 2008 12:52:48 -0800
Message-ID: <47B358A0.7040504@candelatech.com>
References: <47B345D0.1020707@candelatech.com> <20080213123402.43cdbd45@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010409060200030303080704"
Cc: NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:55151 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbYBMUxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 15:53:23 -0500
In-Reply-To: <20080213123402.43cdbd45@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010409060200030303080704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> On Wed, 13 Feb 2008 11:32:32 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
>> I notice that the latest snapshot and git repository for iproute
>> will not compile on FC5 due to not finding __constant_hton* symbols
>> and a lack of the hdlc/ioctl.h file on FC5.
>>
>> I am attaching a patch that appears to fix the problems for me.
>>
>> Please consider applying this or something similar.
>>
>> Signed-off-by:  Ben Greear <greearb@candelatech.com>
>>
>>
>> Thanks,
>> Ben
>>
> 
> I added include/linux/hdlc/ioctl.h to the santized headers in the
> current git.
> 

That seems to fix the hdlc issue, but it still will not link due to missing
symbols:

gcc -Wl,-export-dynamic  ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o iplink_vlan.o link_veth.o ../lib/libnetlink.a ../lib/libutil.a  -lresolv -L../lib -lnetlink -lutil -ldl -o ip
iptunnel.o: In function `parse_args':
iptunnel.c:(.text+0x2c6): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x404): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x48d): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x4a6): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x4e2): undefined reference to `__constant_htons'
iptunnel.o:iptunnel.c:(.text+0x4fb): more undefined references to `__constant_htons' follow
collect2: ld returned 1 exit status
make[1]: *** [ip] Error 1
make[1]: Leaving directory `/root/iproute2/ip'
make: *** [all] Error 2


The attached patch fixes this.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------010409060200030303080704
Content-Type: text/x-patch;
 name="iproute.fc5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute.fc5.patch"

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 228eb4e..0eb5b04 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -2,6 +2,7 @@
 #define _IF_TUNNEL_H_
 
 #include <linux/types.h>
+#include <asm/byteorder.h>
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)

--------------010409060200030303080704--
