From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: RE: [PATCH net] bna: fix Rx data corruption with VLAN stripping
 enabled and MTU > 4096
Date: Sat, 16 Jan 2016 01:27:08 +0000
Message-ID: <2552F74A0BCCBE4DBE2AD218C81B28110867A9DA@avmb3.qlogic.org>
References: <1452861928-17069-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:62491 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751060AbcAPB1Q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 20:27:16 -0500
In-Reply-To: <1452861928-17069-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Friday, January 15, 2016 4:45 AM
> 
> The multi-buffer Rx mode implemented in the past introduced a regression
> that causes a data corruption for received VLAN traffic when VLAN tag
> stripping is enabled. This mode is supported only be newer chipsets (1860)
> and is enabled when MTU > 4096.
> 
> When this mode is enabled Rx queue contains buffers with fixed size
> 2048 bytes. Any incoming packet larger than 2048 is divided into multiple
> buffers that are attached as skb frags in polling routine.
> 
> The driver assumes that all buffers associated with a packet except the last
> one is fully used (e.g. packet with size 5000 are divided into 3 buffers 2048 +
> 2048 + 904 bytes) and ignores true size reported in completions. This
> assumption is usually true but not when VLAN packet is received and VLAN
> tag stripping is enabled. In this case the first buffer is 2044 bytes long but as
> the driver always assumes
> 2048 bytes then 4 extra random bytes are included between the first and the
> second frag. Additionally the driver sets checksum as correct so the packet is
> properly processed by the core.
> 
> The driver needs to check the size of used space in each Rx buffer reported
> by FW and not blindly use the fixed value.

Looks good to me, thanks Ivan!
Reviewed-by: Rasesh Mody <rasesh.mody@qlogic.com>

David - please apply.
