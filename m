From: Marin Mitov <mitov@issp.bas.bg>
Subject: CONFIG_HIGHMEM or CONFIG_HIGHMEM64G in illegal_highdma()
Date: Tue, 6 May 2008 15:35:40 +0300
Message-ID: <200805061535.40424.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759024AbYEFMfr@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

The usage of NETIF_F_HIGHDMA in net drivers make me think its 
purpose is to declare drivers's capability to address RAM above 4GB, OK?

For x86_64 CONFIG_HIGHMEM is not defined, so the function 
illegal_highdma() found in net/core/dev.c returns 0 because 
x86_64 has IOMMU mapping all RAM.

For x86_32 CONFIG_HIGHMEM is defined as 
(CONFIG_HIGHMEM4G || CONFIG_HIGHMEM64G)
While CONFIG_HIGHMEM4G insures RAM is bellow 4GB some checks
are unnecessarily done. 

Should we have CONFIG_HIGHMEM64G in illegal_highdma()
instead of CONFIG_HIGHMEM?

Regards.

Marin Mitov
