From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH 02/12] man: Add a man page for the csum action.
Date: Mon, 7 Mar 2016 06:45:06 -0500
Message-ID: <56DD69C2.4070900@mojatatu.com>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
 <1457093507-25601-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36222 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbcCGLpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 06:45:08 -0500
Received: by mail-ig0-f175.google.com with SMTP id vs8so22498204igb.1
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 03:45:08 -0800 (PST)
In-Reply-To: <1457093507-25601-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-04 07:11 AM, Phil Sutter wrote:
> Cc: Gregoire Baron <baronchon@n7mm.org>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>   man/man8/tc-csum.8 | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 54 insertions(+)
>   create mode 100644 man/man8/tc-csum.8
>
> diff --git a/man/man8/tc-csum.8 b/man/man8/tc-csum.8
> new file mode 100644
> index 0000000000000..9d00aae346af0
> --- /dev/null
> +++ b/man/man8/tc-csum.8
> @@ -0,0 +1,54 @@
> +.TH "Checksum action in tc" 8 "11 Jan 2015" "iproute2" "Linux"
> +
> +.SH NAME
> +csum - checksum update action
> +.SH SYNOPSIS
> +.in +8
> +.ti -8
> +.BR tc " ... " "action csum"
> +.I UPDATE
> +
> +.ti -8
> +.IR UPDATE " := " TARGET " [ " UPDATE " ]"
> +
> +.ti -8
> +.IR TARGET " := { "
> +.BR ip4h " |"
> +.BR icmp " |"
> +.BR igmp " |"
> +.BR tcp " |"
> +.BR udp " |"
> +.BR udplite " |"
> +.IR SWEETS " }"
> +
> +.ti -8
> +.IR SWEETS " := { "
> +.BR and " | " or " | " + " }"
> +.SH DESCRIPTION
> +The
> +.B csum
> +action triggers checksum recalculation of specified packet headers. It is
> +commonly used after packet editing using the
> +.B pedit
> +action to fix for then incorrect checksums.


Would it make sense to add an example? From the commit log:
---

      # In order to DNAT (stateless) IPv4 packet from 192.168.1.100 to
      #  0x12345678 (18.52.86.120), and update the IPv4 header checksum and
      #  the UDP checksum (the last one, only if the packet is UDP).
     tc filter add eth0 prio 1 protocol ip parent ffff: \
       u32 match ip src 192.168.1.100/32 flowid :1 \
         action pedit munge offset 16 u32 set 0x12345678 \
           pipe csum ip and udp

      # In order to alter destination address of IPv6 TCP packets from 
fc00::1
      #  and correct the TCP checksum (nothing happened? except maybe for
      #  checksums in the TCP payload ...).
     tc filter add eth0 prio 1 protocol ipv6 parent ffff: \
       u32 match ip6 src fc00::1/128 match ip6 protocol 0x06 0xff flowid 
:1 \
         action pedit munge offset 24 u32 set 0x12345678 \
           pipe csum tcp

-----

cheers,
jamal
