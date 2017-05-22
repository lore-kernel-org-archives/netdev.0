From: Stephen Hemminger <stephen@networkplumber.org>
Subject: New Coverity defect in BPF verifier
Date: Mon, 22 May 2017 09:05:12 -0700
Message-ID: <20170522090512.38dbcefa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34868 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757638AbdEVQFU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 12:05:20 -0400
Received: by mail-pf0-f177.google.com with SMTP id n23so86547677pfb.2
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 09:05:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Date: Mon, 22 May 2017 04:40:24 -0700
From: scan-admin@coverity.com
To: stephen@networkplumber.org
Subject: New Defects reported by Coverity Scan for Linux


Hi,

Please find the latest report on new defect(s) introduced to Linux found with Coverity Scan.

1 new defect(s) introduced to Linux found with Coverity Scan.
17 defect(s), reported by Coverity Scan earlier, were marked fixed in the recent build analyzed by Coverity Scan.

New defect(s) Reported-by: Coverity Scan
Showing 1 of 1 defect(s)


** CID 1409762:  Control flow issues  (DEADCODE)
/kernel/bpf/verifier.c: 815 in check_pkt_ptr_alignment()


________________________________________________________________________________________________________
*** CID 1409762:  Control flow issues  (DEADCODE)
/kernel/bpf/verifier.c: 815 in check_pkt_ptr_alignment()
809     	}
810     
811     	/* skb->data is NET_IP_ALIGN-ed, but for strict alignment checking
812     	 * we force this to 2 which is universally what architectures use
813     	 * when they don't set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
814     	 */
>>>     CID 1409762:  Control flow issues  (DEADCODE)
>>>     Execution cannot reach the expression "0" inside this statement: "ip_align = (strict ? 2 : 0);".  
815     	ip_align = strict ? 2 : NET_IP_ALIGN;
816     	if ((ip_align + reg_off + off) % size != 0) {
817     		verbose("misaligned packet access off %d+%d+%d size %d\n",
818     			ip_align, reg_off, off, size);
819     		return -EACCES;
820     	}
